/**
* @author       APB
* @description  VertexIntManager: Class used to create the vertex wrappers
*/
public with sharing class VertexIntManager {

    /**
	* @author       APB
	* @description  createRequest method
	* @param		dt Datetime
    * @param		countryCode String
	* @return		VertexMethods
	*/
    public static VertexMethods createRequest(Datetime dt, String countryCode){
        VertexMethods vertexWrapper = new VertexMethods();

        vertexWrapper.transactionTypeCode = 'PURCHASE';
        vertexWrapper.auxId = '723E4D234A111FD087EC4B69ED931D18';
        vertexWrapper.actualDate = dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');

        vertexWrapper.companyInformation = new VertexMethods.CompanyInformation('X', '------------------------X', 'XX');

        vertexWrapper.items = new List<VertexMethods.Item>{
            new VertexMethods.Item(
            '1.00',
            new List<VertexMethods.AssignedParty>{
                new VertexMethods.AssignedParty('5000', 'SHIP_TO'),
                new VertexMethods.AssignedParty('DUMMY123', 'SHIP_FROM'),
                new VertexMethods.AssignedParty('CONTRACT_TO', 'CONTRACT_TO'),
                new VertexMethods.AssignedParty('CONTRACT_FROM', 'CONTRACT_FROM')
            },
            new VertexMethods.ItemAdditionalInfo('Salesforce')
            )
        };

        vertexWrapper.products = new List<VertexMethods.Product>{
            new VertexMethods.Product('NO_PRODUCT', 'NO_PRODUCT')
        };

        vertexWrapper.parties = new List<VertexMethods.Party>{
            new VertexMethods.PartySimple('5000', countryCode),
            new VertexMethods.PartyComplete(countryCode, new List<VertexMethods.TaxRegistration>{
                new VertexMethods.TaxRegistration('VAT', 'XXX', countryCode)
            },
            new VertexMethods.AdditionalInformation('Y')),
            new VertexMethods.PartySimple('CONTRACT_FROM', countryCode),
            new VertexMethods.PartySimple('CONTRACT_TO', countryCode)
            };

        return vertexWrapper;
    }
}