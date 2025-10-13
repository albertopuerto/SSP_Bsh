trigger ContentDocument_Trigger on ContentDocument (after delete) {

    fflib_SObjectDomain.triggerHandler(ContentDocumentDomain.class);

}