public with sharing class ReportFilterAccessController {

    @AuraEnabled(cacheable=true)
    public static List<ReportFilterAccessService.AccessFailure> validate(Id reportId) {
        try {
            return new ReportFilterAccessService(reportId).validate();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}