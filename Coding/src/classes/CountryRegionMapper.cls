public with sharing class CountryRegionMapper {

	/*** HELPER CLASS TO ASSOCIATE A COUNTRY IN THE ORG COUNTRY FIELD TO ITS ASSOCIATED REGION ***/
	
	public static String getRegion(Account ac){
		
		String countryRegion; //local var to hold a countries region value to return to trigger!
		
		//Region is UK
		if(ac.BillingCountry == 'United Kingdom' ||  ac.BillingCountry == 'UK' || ac.BillingCountry == 'Guernsey' || ac.BillingCountry == 'Isle of Man' || 
			ac.BillingCountry == 'Jersey' || ac.BillingCountry == 'Scotland' || ac.BillingCountry == 'Northern Ireland' || ac.BillingCountry == 'Wales'){
			ac.Organisation_Region__c = 'UK';
		//Region is Ireland
		} else if(ac.BillingCountry == 'Ireland'){
			ac.Organisation_Region__c = 'Ireland';
		//Region is US/Canada
		} else if(ac.BillingCountry == 'Canada' || ac.BillingCountry == 'United States' || ac.BillingCountry == 'USA' || ac.BillingCountry == 'America'){
			ac.Organisation_Region__c = 'US/Canada';
		//Region is Europe
		} else if(ac.BillingCountry == 'Albania' || ac.BillingCountry == 'Andorra' || ac.BillingCountry == 'Armenia' || ac.BillingCountry == 'Austria' || ac.BillingCountry == 'Azerbaijan'
			 || ac.BillingCountry == 'Belarus' || ac.BillingCountry == 'Belgium' || ac.BillingCountry == 'Bosnia and Herzegovina' || ac.BillingCountry == 'Bulgaria'
			 || ac.BillingCountry == 'Croatia' || ac.BillingCountry == 'Cyprus' || ac.BillingCountry == 'Czech Republic' || ac.BillingCountry == 'Denmark' || ac.BillingCountry == 'Estonia'
			 || ac.BillingCountry == 'Finland' || ac.BillingCountry == 'France' || ac.BillingCountry == 'Georgia' || ac.BillingCountry == 'Germany' || ac.BillingCountry == 'Greece'
			 || ac.BillingCountry == 'Holy See (vatican City State)' || ac.BillingCountry == 'Hungary' || ac.BillingCountry == 'Iceland' || ac.BillingCountry == 'Italy' || ac.BillingCountry == 'Latvia'
			 || ac.BillingCountry == 'Liechtenstein' || ac.BillingCountry == 'Lithuania' || ac.BillingCountry == 'Luxembourg' || ac.BillingCountry == 'Macedonia, The Former Yugoslav Republic' || ac.BillingCountry == 'Malta'
			 || ac.BillingCountry == 'Moldova, Republic of' || ac.BillingCountry == 'Monaco' || ac.BillingCountry == 'Montenegro' || ac.BillingCountry == 'Netherlands' || ac.BillingCountry == 'Norway'
			 || ac.BillingCountry == 'Poland' || ac.BillingCountry == 'Portugal' || ac.BillingCountry == 'Romania' || ac.BillingCountry == 'San Marino' || ac.BillingCountry == 'Serbia'
			 || ac.BillingCountry == 'Slovakia' || ac.BillingCountry == 'Slovenia' || ac.BillingCountry == 'Spain' || ac.BillingCountry == 'Sweden' || ac.BillingCountry == 'Switzerland' || ac.BillingCountry == 'Ukraine'){
			ac.Organisation_Region__c = 'Europe';
			System.debug('Region is: ' + ac.Organisation_Region__c);	
			return ac.Organisation_Region__c;
		//Region is Rest of World
		} else if(ac.BillingCountry == null || ac.BillingCountry == '' || ac.BillingCountry == 'Unknown' || ac.BillingCountry == 'UNKNOWN') {
			ac.Organisation_Region__c = 'Unknown';
		} else {
			ac.Organisation_Region__c = 'Rest Of World';
		}
		countryRegion = ac.Organisation_Region__c;
		System.debug('Region after if loop is: ' + countryRegion);
		
		return countryRegion;
	}
}