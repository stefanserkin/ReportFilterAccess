public with sharing class ReportFilterAccessService {

    private Id reportId;

    public ReportFilterAccessService(Id reportId) {
        this.reportId = reportId;
    }

    public List<AccessFailure> validate() {
        System.debug('::: entered validate for report id --> ' + reportId);
        return new List<AccessFailure>();
    }

    public class AccessFailure {
        @AuraEnabled
        public Id userId {get;set;}
        @AuraEnabled
        public String fullName {get;set;}
        @AuraEnabled
        public String username {get;set;}
        @AuraEnabled
        public String reportName {get;set;}
        @AuraEnabled
        public String filterName {get;set;}
    }
    
}