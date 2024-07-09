trigger LeadAfterInsert on Lead (after insert) {
    List<Lead> newLeads = Trigger.new;

    System.enqueueJob(new LeadDuplicateEnqueue(newLeads));
}