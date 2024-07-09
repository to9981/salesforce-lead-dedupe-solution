@isTest
public class LeadDuplicateHandlerTest {
    @TestSetup
    static void setupTestData() {
        // Create test data with duplicate keys
        Lead lead1 = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com',
            LeadSource = 'Web',
            Company = 'Google',
            Phone = '4160001111'
        );
        Lead lead2 = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe2@example.com',
            LeadSource = 'Web',
            Company = 'Google',
            Phone = '4160001111'
        );
        insert new List<Lead>{ lead1, lead2 };
    }

    @isTest
    public static void testFindDuplicateLeads() {
        // Retrieve test data
        List<Lead> leads = [
            SELECT Id, FirstName, LastName, Email, LeadSource, Company, Phone
            FROM Lead
            WHERE Email IN ('john.doe@example.com', 'john.doe2@example.com')
        ];

        // Create a mock version of the LeadDuplicateHandler class
        LeadDuplicateInterface mockHandler = (LeadDuplicateInterface) MockUtil.createMock(
            LeadDuplicateHandler.class
        );

        // Call the instance method to test using the mock handler
        Test.startTest();
        mockHandler.findDuplicateLeads(leads);
        Test.stopTest();

        // Verify that lead2 was merged into lead1
        Lead lead1 = [
            SELECT Id, MasterRecordId
            FROM Lead
            WHERE Email = 'john.doe@example.com'
            LIMIT 1
        ];
        Lead lead2 = [
            SELECT Id, MasterRecordId
            FROM Lead
            WHERE Email = 'john.doe2@example.com' AND IsDeleted = TRUE
            ALL ROWS
        ];

        System.assertEquals(
            lead1.Id,
            lead2.MasterRecordId,
            'lead2 should be merged into lead1'
        );

        System.assertEquals(
            lead1.MasterRecordId,
            null,
            'lead1 should be the winner'
        );
    }
}
