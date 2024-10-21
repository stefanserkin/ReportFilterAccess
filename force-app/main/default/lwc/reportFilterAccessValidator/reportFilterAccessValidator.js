import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import validate from '@salesforce/apex/ReportFilterAccessController.validate';

export default class ReportFilterAccessValidator extends LightningElement {
    isLoading = false;
    error;
    
    reportId;

    get validateButtonIsDisabled() {
        const isValidId = this.reportId && 
            this.reportId.startsWith('00O') && 
            (this.reportId.length === 15 || this.reportId.length === 18);
        return !isValidId;
    }

    handleReportIdChange(event) {
        this.reportId = event.target.value;
    }

    handleValidate() {
        this.isLoading = true;
        validate({ reportId: this.reportId })
            .then((result) => {
                console.log('result --> ',JSON.stringify(result));
                this.isLoading = false;
                this.showToast('Success', 'Report filters validated', 'success');
            })
            .catch((error) => {
                this.isLoading = false;
                this.handleError(error);
            });
    }

    /*************************
     * Utils
     *************************/
    handleError(error) {
        let message = 'Unknown error';
        if (Array.isArray(error.body)) {
            message = error.body.map((e) => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            message = error.body.message;
        }
        this.showToast('Error', message, 'error');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }

}