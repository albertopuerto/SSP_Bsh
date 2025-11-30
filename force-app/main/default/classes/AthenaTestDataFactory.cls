@IsTest
public with sharing class AthenaTestDataFactory {

    /**
     * @description load valid Athena paylod from Static Resources
     * @param resourceName name of the existing static resource
     * @return String of the static resource file for specific use case
     */
    public static String loadJson(String resourceName){

        StaticResource sr;

        // exception handlig for easy debug :)
        if(String.isBlank(resourceName)){
            throw new IllegalArgumentException('Resource name cannot be empty.');
        }

        try{
            sr = [SELECT Body FROM StaticResource WHERE Name = : resourceName LIMIT 1];
        }catch (Exception e){
            throw new IllegalArgumentException('Static resource not found.');
        }

        return sr.Body.toString();
    }

}