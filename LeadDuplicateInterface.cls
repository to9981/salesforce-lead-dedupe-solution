public interface LeadDuplicateInterface {
    List<String> generateKeys(Lead lead);
    void processDuplicateLeads(Map<String, List<Lead>> leadMap);
    void mergeDuplicateLeads(List<Lead> duplicateLeads);
    void findDuplicateLeads(List<Lead> leads);
}
