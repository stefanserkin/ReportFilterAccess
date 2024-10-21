public with sharing class ReportFilterAccessService {

    private Id reportId;

    public ReportFilterAccessService(Id reportId) {
        this.reportId = reportId;
    }

    public List<AccessFailure> validate() {
        System.debug('::: entered validate for report id --> ' + this.reportId);
        return new List<AccessFailure>();
    }

    private Boolean userHasAccess(Id userId) {
        Boolean hasAccess = false;
        UserRecordAccess ura = [
            SELECT RecordId, HasReadAccess 
              FROM UserRecordAccess 
             WHERE UserId = :userId
               AND RecordId = :this.reportId
              WITH USER_MODE
             LIMIT 1
        ];
        if (ura.HasReadAccess) {
            hasAccess = true;
        }
        return hasAccess;
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