/**
 * @description       : Utils class for docusign.
 * @author            : APB
**/
public with sharing class DocuSignUtils {

    /**
	* @author       APB
	* @description  Method that get the emails of the signers group member
	* @return		List<EmailWrapper>
	*/
    @InvocableMethod(label='Get email of selected Public Group Members' description='Method to get the email of the Signers group member ')
public static List<EmailWrapper> getGroupMemberEmails() {

    //1.- Validate groupNames is not empty or null

    //2.- Query properly done in another selector class fflib
    List<User> lstUsers = new UserSelector().selectGetActiveSignerUsers();

    List<EmailWrapper> results = new List<EmailWrapper>();
    EmailWrapper ew = new EmailWrapper();
    ew.emails = new List<String>();
        // Your logic to fetch emails
        for (User us : lstUsers) {
            ew.emails.add(us.Email);
            results.add(ew);
        }
        return results;
}

/**
	* @author       APB
	* @description  OutputVariables class has the list of files to be signed
	*/
    public class EmailWrapper {
        @InvocableVariable(label='emails' description='list of emails')
        public List<String> emails;
    }

}