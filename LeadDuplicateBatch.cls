public class LeadDuplicateBatch implements Database.Batchable<sObject>, Database.Stateful {
    private Integer recordsProcessed = 0;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            [
                SELECT Id, LeadSource, FirstName, LastName, Email, Phone
                FROM Lead
                WHERE
                    Email != NULL
                    AND Phone != NULL
                    AND LastName != NULL
                    AND LeadSource != NULL
            ]
        );
    }

    public void execute(Database.BatchableContext BC, List<Lead> scope) {
        LeadDuplicateHandler handler = new LeadDuplicateHandler();
        handler.findDuplicateLeads(scope);
        recordsProcessed += scope.size();
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('Total records processed: ' + recordsProcessed);
    }
}
