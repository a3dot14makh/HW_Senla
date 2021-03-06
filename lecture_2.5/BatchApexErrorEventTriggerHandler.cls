public class BatchApexErrorEventTriggerHandler {
    
    public static void onAfterInsert(List<BatchApexErrorEvent> errorEvents) {
        List<Error_Log__c> records = new List<Error_Log__c>();
        Set<Id> asyncApexJobIds = new Set<Id>();

        for (BatchApexErrorEvent evt : errorEvents) {
            asyncApexJobIds.add(evt.AsyncApexJobId);
        }
        Map<Id, AsyncApexJob> jobs = new Map<Id, AsyncApexJob>(
            AsyncApexJobManager.getById(asyncApexJobIds)
        );

        for (BatchApexErrorEvent evt : errorEvents) {
            if (jobs.get(evt.AsyncApexJobId).ApexClass.Name == DeleteFlightsBatch.class.getName()) {

                for (String item : evt.JobScope.split(',')) {
                    Error_Log__c error = new Error_Log__c(
                        JobId__c = jobs.get(evt.AsyncApexJobId).ParentJobId,
                        Error__c = evt.ExceptionType,
                        Records__c = (Id) item
                    );
                    records.add(error);
                }
            }
        }
        insert records;
    }
}
