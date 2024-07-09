public class LeadDuplicateEnqueue implements Queueable {
    private List<Lead> leads;

    public LeadDuplicateEnqueue(List<Lead> leads) {
        this.leads = leads;
    }

    public void execute(QueueableContext context) {
        LeadDuplicateBatch leadBatch = new LeadDuplicateBatch();
        if (this.leads.size() > 0) {
            Database.executeBatch(leadBatch, 200);
        }
    }
}
