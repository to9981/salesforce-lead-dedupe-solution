public class LeadDuplicateHandler implements LeadDuplicateInterface {
    private static Boolean debugEnabled = true;
    private static Set<Id> processedLeads = new Set<Id>();
    private LeadDuplicateInterface handler;

    // Constructor used by batch job
    public LeadDuplicateHandler() {
        this.handler = this;
    }
    // Constructor used by test class for dependency injection
    public LeadDuplicateHandler(LeadDuplicateInterface handler) {
        this.handler = handler;
    }

    // Instance method to find duplicate leads
    public void findDuplicateLeads(List<Lead> leads) {
        findDuplicateLeads(leads, this.handler);
    }

    // Instance method with additional handler parameter(can be a mock handler)
    public void findDuplicateLeads(
        List<Lead> leads,
        LeadDuplicateInterface handler
    ) {
        //Map of dup keys and matched leads
        Map<String, List<Lead>> leadMap = new Map<String, List<Lead>>();

        for (Lead lead : leads) {
            List<String> keys = handler.generateKeys(lead);
            log('Lead id: ' + lead.Id);
            for (String key : keys) {
                log('Key for this lead: ' + key);
                if (!leadMap.containsKey(key)) {
                    leadMap.put(key, new List<Lead>{ lead });
                } else {
                    List<Lead> leadsForThisKey = leadMap.get(key);
                    if (!leadsForThisKey.contains(lead)) {
                        leadsForThisKey.add(lead);
                    }
                }
            }
        }
        handler.processDuplicateLeads(leadMap);
    }

    //Generate dup keys based on LeadSource has to be matched, 2 out of other 3 fields matched.
    public List<String> generateKeys(Lead lead) {
        List<String> duplicateKeys = new List<String>();
        if (
            lead.LeadSource != null &&
            lead.FirstName != null &&
            lead.LastName != null &&
            lead.Email != null
        ) {
            duplicateKeys.add(
                lead.LeadSource +
                    ':' +
                    lead.FirstName +
                    lead.LastName +
                    ':' +
                    lead.Email
            );
        }

        if (
            lead.LeadSource != null &&
            lead.FirstName != null &&
            lead.LastName != null &&
            lead.Phone != null
        ) {
            duplicateKeys.add(
                lead.LeadSource +
                    ':' +
                    lead.FirstName +
                    lead.LastName +
                    ':' +
                    lead.Phone
            );
        }

        if (
            lead.LeadSource != null &&
            lead.Email != null &&
            lead.Phone != null
        ) {
            duplicateKeys.add(
                lead.LeadSource + ':' + lead.Email + ':' + lead.Phone
            );
        }
        log('duplicateKeys are: ' + duplicateKeys);
        return duplicateKeys;
    }

    //Determine duplicated leads to be merged
    public void processDuplicateLeads(Map<String, List<Lead>> leadMap) {
        for (String s : leadMap.keySet()) {
            log('Key: ' + s);
            log('Lead Ids: ' + leadMap.get(s).size());
            List<Lead> duplicateLeads = new List<Lead>();
            if (leadMap.get(s).size() > 1) {
                duplicateLeads = leadMap.get(s);
                log('duplicateLeads: ' + duplicateLeads.size());
                handler.mergeDuplicateLeads(duplicateLeads);
            }
        }
        log('leadMap keyset is: ' + leadMap.keySet());
    }

    //Merge leads
    public void mergeDuplicateLeads(List<Lead> duplicateLeads) {
        log('Merging duplicates: ' + duplicateLeads.size());

        if (duplicateLeads.size() <= 1) {
            log('Not enough leads to merge: ' + duplicateLeads);
            return;
        }

        Lead masterLead = duplicateLeads.get(0);

        for (Integer i = 1; i < duplicateLeads.size(); i++) {
            Lead dupLead = duplicateLeads.get(i);
            log('processedLeads before if: ' + processedLeads);
            if (!processedLeads.contains(dupLead.Id)) {
                try {
                    Database.MergeResult result = Database.merge(
                        masterLead,
                        dupLead,
                        false
                    );
                    processedLeads.add(dupLead.Id);
                    log(
                        'processedLeads after add dupLead.Id: ' + processedLeads
                    );
                    if (result.isSuccess()) {
                        log(
                            'Merge succeeded. Master record Id: ' +
                            result.getId()
                        );
                    } else {
                        log('Merge failed with errors: ' + result.getErrors());
                    }
                } catch (Exception e) {
                    log(
                        'Error during merge of lead ID ' +
                            dupLead.Id +
                            ': ' +
                            e.getMessage()
                    );
                }
            } else {
                log('Lead already merged: ' + dupLead.Id);
            }
        }
    }

    private static void log(String message) {
        if (debugEnabled) {
            System.debug(message);
        }
    }
}
