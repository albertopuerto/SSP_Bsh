/**
* @author       TLQ1KOR
* @date         05/19/2025
* @description  BSSP-6689:Lock Record until approval
*/
public with sharing class GroupService {
    public class GroupData {
        public String name;
        public String id;
        public Set<String> users = new Set<String>(); 
        public Set<String> roles = new Set<String>();
    }
    @TestVisible private static List<sbaa__Approver__c> approvers_for_testing;
    @TestVisible private static Boolean user_in_group_result;
    @TestVisible private static List<GroupService.GroupData> groups_for_testing;
    
    @InvocableMethod(label='Quote is read only' description='Checks if the quote is read only')
    public static List<OutputVariables> callIsQuoteReadOnly(List<InputVariables> parameters) {
        List<OutputVariables> outputVariables = new List<OutputVariables>();
        try {
            for (InputVariables parameter : parameters) {
                Boolean isQuoteReadOnly = isQuoteReadOnly(parameter.userId, parameter.quoteId);
                OutputVariables outputVariable = new OutputVariables();
                outputVariable.isQuoteReadOnly = isQuoteReadOnly;
                outputVariables.add(outputVariable);
            }
            Logger.info('Successfully processed quote read-only status check');
        } catch (Exception ex) {
            Logger.error('Error processing quote read-only status check', ex);
            throw ex;
        } finally {
            Logger.saveLog();
        }
        return outputVariables;
    }
    @TestVisible private static List<sbaa__Approval__c> approvals_for_testing;
    @TestVisible private static Boolean isQuoteReadOnly(Id userId, Id quoteId) {
        
        try {
            Logger.debug('Checking if quote is read-only. UserId: ' + userId + ', QuoteId: ' + quoteId);
            
            List<SBQQ__Quote__c> quotes = [SELECT Id, OwnerId FROM SBQQ__Quote__c WHERE Id = :quoteId LIMIT 1];
            if (quotes.isEmpty()) {
                Logger.debug('Quote not found. QuoteId: ' + quoteId);
                return false;
            }
            
            SBQQ__Quote__c quote = quotes[0];
            
            //  List<sbaa__Approval__c> approvals = [SELECT Id, sbaa__ApproverField__c FROM sbaa__Approval__c WHERE Quote__c = :quoteId AND sbaa__Status__c IN ('Requested' , 'Assigned')]; 
            List<sbaa__Approval__c> approvals;
            
            if (Test.isRunningTest() && approvals_for_testing != null) {
                approvals = approvals_for_testing;
            } else {
                approvals = [SELECT Id, sbaa__ApproverField__c, sbaa__Approver__c,CreatedById FROM sbaa__Approval__c 
                             WHERE Quote__c = :quoteId AND sbaa__Status__c IN ('Requested', 'Assigned','Recalled')];
            }
            
            if (approvals.isEmpty()) {
                Logger.debug('No pending approvals found for quote: ' + quoteId);
                return true;
            }
            
            Logger.debug('Found ' + approvals.size() + ' pending approvals for quote: ' + quoteId);
            
            Set<Id> sIdApprovals = new Set<Id>();
            for (sbaa__Approval__c approval : approvals) {
                if (approval.Id != null){
                    sIdApprovals.add(approval.sbaa__Approver__c);
                }
                
            }
            for (sbaa__Approval__c approval : approvals) {
                if (approval.sbaa__ApproverField__c != null && quote.get(approval.sbaa__ApproverField__c) == userId) {
                    Logger.debug('User is the approver specified in the ApproverField: ' + approval.sbaa__ApproverField__c);
                    return true;
                }
            }
             for (sbaa__Approval__c approval : approvals) {
                if (approval.CreatedById == userId) {
                    Logger.debug('User created this recalled approval and can edit. UserId: ' + userId);
                    return true;
                }
            }
            
            //List<sbaa__Approver__c> approvers = [SELECT Id, sbaa__User__c, sbaa__GroupId__c FROM sbaa__Approver__c WHERE Id IN :sIdApprovals];
            List<sbaa__Approver__c> approvers;
            if (Test.isRunningTest() && approvers_for_testing != null) {
                approvers = approvers_for_testing;
            } else {
                approvers = [SELECT Id, sbaa__User__c, sbaa__GroupId__c FROM sbaa__Approver__c WHERE Id IN :sIdApprovals];
                System.debug('>>> Using database approvers, count: ' + approvers.size());
            }
            if (approvers.isEmpty()) {
                Logger.debug('No approvers found for the pending approvals');
                return false;
            }
            
            for (sbaa__Approver__c approver : approvers) {
                if (approver.sbaa__User__c == userId) {
                    Logger.debug('User is directly specified as an approver. UserId: ' + userId);
                    return true;
                }
                else if (approver.sbaa__GroupId__c != null) {
                    Boolean userInGroup = isUserInGroup(userId, approver.sbaa__GroupId__c);
                    Logger.debug('Checked if user is in approver group. UserId: ' + userId + ', GroupId: ' + approver.sbaa__GroupId__c + ', Result: ' + userInGroup);
                    return userInGroup;
                }
            }
            
            Logger.debug('User is not an approver for this quote. UserId: ' + userId + ', QuoteId: ' + quoteId);
            return false;
        } catch (Exception ex) {
            Logger.error('Error while checking if quote is read-only', ex);
            return false;
        }
    }
    @TestVisible
    private static Boolean isUserInGroup(Id userId, Id groupId) {
        if (Test.isRunningTest() && user_in_group_result != null) {
            return user_in_group_result;
        }
        try {
            if (userId == null || groupId == null) {
                Logger.debug('User ID or Group ID is null. UserId: ' + userId + ', GroupId: ' + groupId);
                return false;
            }
            
            List<GroupData> cachedGroups = getGroupsFromCache();
            Logger.debug('Retrieved ' + cachedGroups.size() + ' cached groups');
            
            Map<String, GroupData> groupMap = new Map<String, GroupData>();
            for (GroupData groupAux : cachedGroups) {
                groupMap.put(groupAux.id, groupAux);
            }
            
            if (!groupMap.containsKey(String.valueOf(groupId))) {
                Logger.debug('Group not found in cache. GroupId: ' + groupId);
                return false;
            }
            
            GroupData groupData = groupMap.get(String.valueOf(groupId));  
            
            if (groupData.users.contains(String.valueOf(userId))) {
                Logger.debug('User is directly in the group. UserId: ' + userId + ', GroupId: ' + groupId);
                return true;
            }
            
            User usr = [SELECT Id, UserRoleId FROM User WHERE Id = :userId LIMIT 1];
            
            if (usr.UserRoleId == null) {
                Logger.debug('User has no role assigned. UserId: ' + userId);
                return false; 
            }
            
            if (groupData.roles.contains(String.valueOf(usr.UserRoleId))) {
                Logger.debug('User\'s role is in the group. UserId: ' + userId + ', RoleId: ' + usr.UserRoleId + ', GroupId: ' + groupId);
                return true;
            }
            
            Logger.debug('User is not in the group. UserId: ' + userId + ', GroupId: ' + groupId);
            return false;
        } catch (Exception ex) {
            Logger.error('Error while checking if user is in group', ex);
            return false;
        }
    }
    
    
    public static List<GroupData> getGroupsFromCache() {
        if (Test.isRunningTest() && groups_for_testing != null) {
            System.debug('>>> getGroupsFromCache called, groups_for_testing size: ' + groups_for_testing.size());
            return groups_for_testing; // Critical: return the mock data here
        } else {
            if (groups_for_testing != null) {
                System.debug('>>> getGroupsFromCache called, groups_for_testing size: ' + groups_for_testing.size());
            } else {
                System.debug('>>> getGroupsFromCache called, groups_for_testing: null');
            }
        }
        try {
            // Try to retrieve data from cache
            String cacheKey = 'groupCache';
            Object cachedData = Cache.Org.get(cacheKey);
            
            if (cachedData != null) {
                Logger.debug('Retrieved groups from cache. CacheKey: ' + cacheKey);
                return (List<GroupData>) cachedData;
            }
            
            // If no data in cache, query Salesforce
            Logger.debug('Groups not found in cache, querying from database. CacheKey: ' + cacheKey);
            List<GroupData> groups = getAllGroupsWithUsersAndRoles();
            
            // Save in cache for future queries (expires according to partition configuration)
            Cache.Org.put(cacheKey, groups);
            Logger.debug('Stored ' + groups.size() + ' groups in cache. CacheKey: ' + cacheKey);
            
            return groups;
        } catch (Exception ex) {
            Logger.error('Error retrieving groups from cache', ex);
            return new List<GroupData>();
        }
    }
    
    private static List<GroupData> getAllGroupsWithUsersAndRoles() {
        try {
            //All groups in the org
            Map<Id, Group> allGroups = new Map<Id, Group>([SELECT Id, Name, DeveloperName, type FROM Group WHERE Type IN ('Queue', 'RoleAndSubordinates', 'Regular')]);
            Logger.debug('Retrieved ' + allGroups.size() + ' groups');
            
            // All group members in the org
            List<GroupMember> groupMembers = [SELECT GroupId, UserOrGroupId FROM GroupMember];
            Logger.debug('Retrieved ' + groupMembers.size() + ' group members');
            
            Map<Id, Set<Id>> groupToUsers = new Map<Id, Set<Id>>();
            Map<Id, Set<Id>> groupToSubgroups = new Map<Id, Set<Id>>();
            
            // for each group, get its users and subgroups
            for (GroupMember gm : groupMembers) {
                if (allGroups.containsKey(gm.GroupId)) {
                    if (allGroups.containsKey(gm.UserOrGroupId)) {
                        // The user is a group, add to our subgroups set
                        if (!groupToSubgroups.containsKey(gm.GroupId)) {
                            groupToSubgroups.put(gm.GroupId, new Set<Id>());
                        }
                        groupToSubgroups.get(gm.GroupId).add(gm.UserOrGroupId);
                    } else {
                        // The user is an individual user, add to our users set
                        if (!groupToUsers.containsKey(gm.GroupId)) {
                            groupToUsers.put(gm.GroupId, new Set<Id>());
                        }
                        groupToUsers.get(gm.GroupId).add(gm.UserOrGroupId);
                    }
                }
            }
            
            // Get the roles of the groups
            Map<Id, String> groupRoles = new Map<Id, String>();
            for (Group g : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName != NULL]) {
                //add the role of the group
                groupRoles.put(g.Id, g.DeveloperName);
            }
            
            Map<Id, GroupData> groupDataMap = new Map<Id, GroupData>();
            
            // Build the group data for each group
            for (Id groupId : allGroups.keySet()) {
                GroupData data = buildGroupData(groupId, allGroups, groupToUsers, groupToSubgroups, groupRoles, new Set<Id>());
                groupDataMap.put(groupId, data);
            }
            
            Logger.debug('Successfully built group data structure with ' + groupDataMap.size() + ' groups');
            return groupDataMap.values();
        } catch (Exception ex) {
            Logger.error('Error retrieving all groups with users and roles', ex);
            return new List<GroupData>();
        }
    }
    
    // recursive method to build the group data
    @TestVisible
    private static GroupData buildGroupDataForTesting(Id groupId, 
                                                      Map<Id, Group> allGroups,
                                                      Map<Id, Set<Id>> groupToUsers,
                                                      Map<Id, Set<Id>> groupToSubgroups,
                                                      Map<Id, String> groupRoles,
                                                      Set<Id> visitedGroups) {
                                                          return buildGroupData(groupId, allGroups, groupToUsers, groupToSubgroups, groupRoles, visitedGroups);
                                                      }
    private static GroupData buildGroupData(Id groupId, 
                                            Map<Id, Group> allGroups,
                                            Map<Id, Set<Id>> groupToUsers,
                                            Map<Id, Set<Id>> groupToSubgroups,
                                            Map<Id, String> groupRoles,
                                            Set<Id> visitedGroups) {
                                                try {
                                                    // avoid infinite loops
                                                    if (visitedGroups.contains(groupId)) {
                                                        Logger.debug('Group already visited, avoiding infinite loop. GroupId: ' + groupId);
                                                        return new GroupData();
                                                    }
                                                    visitedGroups.add(groupId);
                                                    
                                                    // Build the group data
                                                    GroupData gData = new GroupData();
                                                    gData.name = allGroups.get(groupId).DeveloperName;
                                                    gData.id = String.valueOf(groupId);
                                                    
                                                    // add users of the group
                                                    if (groupToUsers.containsKey(groupId)) {
                                                        for (Id userId : groupToUsers.get(groupId)) {
                                                            gData.users.add(String.valueOf(userId));
                                                        }
                                                        Logger.debug('Added ' + gData.users.size() + ' users to group: ' + groupId);
                                                    }
                                                    
                                                    // add roles of the group
                                                    if (groupRoles.containsKey(groupId)) {
                                                        gData.roles.add(groupRoles.get(groupId));
                                                        Logger.debug('Added role to group. GroupId: ' + groupId + ', Role: ' + groupRoles.get(groupId));
                                                    }
                                                    
                                                    // Process subgroups recursively
                                                    if (groupToSubgroups.containsKey(groupId)) {
                                                        for (Id subGroupId : groupToSubgroups.get(groupId)) {
                                                            Logger.debug('Processing subgroup. ParentGroupId: ' + groupId + ', SubGroupId: ' + subGroupId);
                                                            GroupData subGroupData = buildGroupData(subGroupId, allGroups, groupToUsers, groupToSubgroups, groupRoles, visitedGroups);
                                                            
                                                            // Add users and roles from subgroups to parent group
                                                            gData.users.addAll(subGroupData.users);
                                                            gData.roles.addAll(subGroupData.roles);
                                                        }
                                                        Logger.debug('Processed all subgroups for group: ' + groupId + 
                                                                     '. Total users: ' + gData.users.size() + 
                                                                     ', Total roles: ' + gData.roles.size());
                                                    }
                                                    
                                                    return gData;
                                                } catch (Exception ex) {
                                                    Logger.error('Error building group data for group: ' + groupId, ex);
                                                    return new GroupData();
                                                }
                                            }
    @TestVisible
    private static Boolean isUserInGroupForTesting(Id userId, Id groupId) {
        return isUserInGroup(userId, groupId);
    }
    
    
    public class InputVariables {
        @InvocableVariable(label='User Id' description='Id of the user' required=true)
        public String userId;
        @InvocableVariable(label='Quote Id' description='Id of the quote' required=true)
        public String quoteId;
    }
    
    public class OutputVariables {
        @InvocableVariable(label='Read only quote' description='Indicates if the quote is read only' required=true)
        public Boolean isQuoteReadOnly;
    }    
}