//
//  VectorMap.swift
//  VectorMapAnimation
//
//  Created by Kishore Kumar on 7/16/20.
//  Copyright © 2020 OctagonGo. All rights reserved.
//

import Foundation
import OctagonAnalyticsService

struct VectorMap {
    
    var countryCode: String!
    var value: Float!
   
    //MARK: Functions
    init(_ responseModel: VideoEntryService) {
        self.countryCode = responseModel.title
        self.value = Float(responseModel.value)
    }
    
}

extension String {
    var toRange: ClosedRange<Int>? {
        let commaRemoved = replacingOccurrences(of: ",", with: "")
        let splitted = commaRemoved.components(separatedBy: " to ")
        if let firstHalf = splitted.first,
            let lastHalf = splitted.last,
            let floor = Int(firstHalf),
            let ceil = Int(lastHalf) {
            return floor...ceil
        }
        return nil
    }
}

extension ClosedRange where Bound == Int {
    var toString: String {
        return "\(NSNumber(value: lowerBound).formattedWithSeparator) to \(NSNumber(value: upperBound).formattedWithSeparator)"
    }
    var toKAndMString: String {
           return "\(Double(lowerBound).formatToKandM) to \(Double(upperBound).formatToKandM)"
    }
}


let countryCodeArray = [
 [
   "code": "AFG",
   "country": "Afghanistan"
 ],
 [
   "code": "ALB",
   "country": "Albania"
 ],
 [
   "code": "DZA",
   "country": "Algeria"
 ],
 [
   "code": "AND",
   "country": "Andorra"
 ],
 [
   "code": "AGO",
   "country": "Angola"
 ],
 [
   "code": "AIA",
   "country": "Anguilla"
 ],
 [
   "code": "ATG",
   "country": "Antigua and Barbuda"
 ],
 [
   "code": "ARG",
   "country": "Argentina"
 ],
 [
   "code": "ARM",
   "country": "Armenia"
 ],
 [
   "code": "ABW",
   "country": "Aruba"
 ],
 [
   "code": "AUS",
   "country": "Australia"
 ],
 [
   "code": "AUT",
   "country": "Austria"
 ],
 [
   "code": "AZE",
   "country": "Azerbaijan"
 ],
 [
   "code": "BHS",
   "country": "Bahamas"
 ],
 [
   "code": "BHR",
   "country": "Bahrain"
 ],
 [
   "code": "BGD",
   "country": "Bangladesh"
 ],
 [
   "code": "BRB",
   "country": "Barbados"
 ],
 [
   "code": "BLR",
   "country": "Belarus"
 ],
 [
   "code": "BEL",
   "country": "Belgium"
 ],
 [
   "code": "BLZ",
   "country": "Belize"
 ],
 [
   "code": "BEN",
   "country": "Benin"
 ],
 [
   "code": "BMU",
   "country": "Bermuda"
 ],
 [
   "code": "BTN",
   "country": "Bhutan"
 ],
 [
   "code": "BOL",
   "country": "Bolivia"
 ],
 [
   "code": "BES",
   "country": "Bonaire Sint Eustatius and Saba"
 ],
 [
   "code": "BIH",
   "country": "Bosnia and Herzegovina"
 ],
 [
   "code": "BWA",
   "country": "Botswana"
 ],
 [
   "code": "BRA",
   "country": "Brazil"
 ],
 [
   "code": "VGB",
   "country": "British Virgin Islands"
 ],
 [
   "code": "BRN",
   "country": "Brunei"
 ],
 [
   "code": "BGR",
   "country": "Bulgaria"
 ],
 [
   "code": "BFA",
   "country": "Burkina Faso"
 ],
 [
   "code": "BDI",
   "country": "Burundi"
 ],
 [
   "code": "KHM",
   "country": "Cambodia"
 ],
 [
   "code": "CMR",
   "country": "Cameroon"
 ],
 [
   "code": "CAN",
   "country": "Canada"
 ],
 [
   "code": "CPV",
   "country": "Cape Verde"
 ],
 [
   "code": "CYM",
   "country": "Cayman Islands"
 ],
 [
   "code": "CAF",
   "country": "Central African Republic"
 ],
 [
   "code": "TCD",
   "country": "Chad"
 ],
 [
   "code": "CHL",
   "country": "Chile"
 ],
 [
   "code": "CHN",
   "country": "China"
 ],
 [
   "code": "COL",
   "country": "Colombia"
 ],
 [
   "code": "COM",
   "country": "Comoros"
 ],
 [
   "code": "COG",
   "country": "Congo"
 ],
 [
   "code": "CRI",
   "country": "Costa Rica"
 ],
 [
   "code": "CIV",
   "country": "Cote d'Ivoire"
 ],
 [
   "code": "HRV",
   "country": "Croatia"
 ],
 [
   "code": "CUB",
   "country": "Cuba"
 ],
 [
   "code": "CUW",
   "country": "Curacao"
 ],
 [
   "code": "CYP",
   "country": "Cyprus"
 ],
 [
   "code": "CZE",
   "country": "Czech Republic"
 ],
 [
   "code": "COD",
   "country": "Democratic Republic of Congo"
 ],
 [
   "code": "DNK",
   "country": "Denmark"
 ],
 [
   "code": "DJI",
   "country": "Djibouti"
 ],
 [
   "code": "DMA",
   "country": "Dominica"
 ],
 [
   "code": "DOM",
   "country": "Dominican Republic"
 ],
 [
   "code": "ECU",
   "country": "Ecuador"
 ],
 [
   "code": "EGY",
   "country": "Egypt"
 ],
 [
   "code": "SLV",
   "country": "El Salvador"
 ],
 [
   "code": "GNQ",
   "country": "Equatorial Guinea"
 ],
 [
   "code": "ERI",
   "country": "Eritrea"
 ],
 [
   "code": "EST",
   "country": "Estonia"
 ],
 [
   "code": "ETH",
   "country": "Ethiopia"
 ],
 [
   "code": "FRO",
   "country": "Faeroe Islands"
 ],
 [
   "code": "FLK",
   "country": "Falkland Islands"
 ],
 [
   "code": "FJI",
   "country": "Fiji"
 ],
 [
   "code": "FIN",
   "country": "Finland"
 ],
 [
   "code": "FRA",
   "country": "France"
 ],
 [
   "code": "PYF",
   "country": "French Polynesia"
 ],
 [
   "code": "GAB",
   "country": "Gabon"
 ],
 [
   "code": "GMB",
   "country": "Gambia"
 ],
 [
   "code": "GEO",
   "country": "Georgia"
 ],
 [
   "code": "DEU",
   "country": "Germany"
 ],
 [
   "code": "GHA",
   "country": "Ghana"
 ],
 [
   "code": "GIB",
   "country": "Gibraltar"
 ],
 [
   "code": "GRC",
   "country": "Greece"
 ],
 [
   "code": "GRL",
   "country": "Greenland"
 ],
 [
   "code": "GRD",
   "country": "Grenada"
 ],
 [
   "code": "GUM",
   "country": "Guam"
 ],
 [
   "code": "GTM",
   "country": "Guatemala"
 ],
 [
   "code": "GGY",
   "country": "Guernsey"
 ],
 [
   "code": "GIN",
   "country": "Guinea"
 ],
 [
   "code": "GNB",
   "country": "Guinea-Bissau"
 ],
 [
   "code": "GUY",
   "country": "Guyana"
 ],
 [
   "code": "HTI",
   "country": "Haiti"
 ],
 [
   "code": "HND",
   "country": "Honduras"
 ],
 [
   "code": "HKG",
   "country": "Hong Kong"
 ],
 [
   "code": "HUN",
   "country": "Hungary"
 ],
 [
   "code": "ISL",
   "country": "Iceland"
 ],
 [
   "code": "IND",
   "country": "India"
 ],
 [
   "code": "IDN",
   "country": "Indonesia"
 ],
 [
   "code": "IRN",
   "country": "Iran"
 ],
 [
   "code": "IRQ",
   "country": "Iraq"
 ],
 [
   "code": "IRL",
   "country": "Ireland"
 ],
 [
   "code": "IMN",
   "country": "Isle of Man"
 ],
 [
   "code": "ISR",
   "country": "Israel"
 ],
 [
   "code": "ITA",
   "country": "Italy"
 ],
 [
   "code": "JAM",
   "country": "Jamaica"
 ],
 [
   "code": "JPN",
   "country": "Japan"
 ],
 [
   "code": "JEY",
   "country": "Jersey"
 ],
 [
   "code": "JOR",
   "country": "Jordan"
 ],
 [
   "code": "KAZ",
   "country": "Kazakhstan"
 ],
 [
   "code": "KEN",
   "country": "Kenya"
 ],
 [
   "code": "OWID_KOS",
   "country": "Kosovo"
 ],
 [
   "code": "KWT",
   "country": "Kuwait"
 ],
 [
   "code": "KGZ",
   "country": "Kyrgyzstan"
 ],
 [
   "code": "LAO",
   "country": "Laos"
 ],
 [
   "code": "LVA",
   "country": "Latvia"
 ],
 [
   "code": "LBN",
   "country": "Lebanon"
 ],
 [
   "code": "LSO",
   "country": "Lesotho"
 ],
 [
   "code": "LBR",
   "country": "Liberia"
 ],
 [
   "code": "LBY",
   "country": "Libya"
 ],
 [
   "code": "LIE",
   "country": "Liechtenstein"
 ],
 [
   "code": "LTU",
   "country": "Lithuania"
 ],
 [
   "code": "LUX",
   "country": "Luxembourg"
 ],
 [
   "code": "MKD",
   "country": "Macedonia"
 ],
 [
   "code": "MDG",
   "country": "Madagascar"
 ],
 [
   "code": "MWI",
   "country": "Malawi"
 ],
 [
   "code": "MYS",
   "country": "Malaysia"
 ],
 [
   "code": "MDV",
   "country": "Maldives"
 ],
 [
   "code": "MLI",
   "country": "Mali"
 ],
 [
   "code": "MLT",
   "country": "Malta"
 ],
 [
   "code": "MRT",
   "country": "Mauritania"
 ],
 [
   "code": "MUS",
   "country": "Mauritius"
 ],
 [
   "code": "MEX",
   "country": "Mexico"
 ],
 [
   "code": "MDA",
   "country": "Moldova"
 ],
 [
   "code": "MCO",
   "country": "Monaco"
 ],
 [
   "code": "MNG",
   "country": "Mongolia"
 ],
 [
   "code": "MNE",
   "country": "Montenegro"
 ],
 [
   "code": "MSR",
   "country": "Montserrat"
 ],
 [
   "code": "MAR",
   "country": "Morocco"
 ],
 [
   "code": "MOZ",
   "country": "Mozambique"
 ],
 [
   "code": "MMR",
   "country": "Myanmar"
 ],
 [
   "code": "NAM",
   "country": "Namibia"
 ],
 [
   "code": "NPL",
   "country": "Nepal"
 ],
 [
   "code": "NLD",
   "country": "Netherlands"
 ],
 [
   "code": "NCL",
   "country": "New Caledonia"
 ],
 [
   "code": "NZL",
   "country": "New Zealand"
 ],
 [
   "code": "NIC",
   "country": "Nicaragua"
 ],
 [
   "code": "NER",
   "country": "Niger"
 ],
 [
   "code": "NGA",
   "country": "Nigeria"
 ],
 [
   "code": "MNP",
   "country": "Northern Mariana Islands"
 ],
 [
   "code": "NOR",
   "country": "Norway"
 ],
 [
   "code": "OMN",
   "country": "Oman"
 ],
 [
   "code": "PAK",
   "country": "Pakistan"
 ],
 [
   "code": "PSE",
   "country": "Palestine"
 ],
 [
   "code": "PAN",
   "country": "Panama"
 ],
 [
   "code": "PNG",
   "country": "Papua New Guinea"
 ],
 [
   "code": "PRY",
   "country": "Paraguay"
 ],
 [
   "code": "PER",
   "country": "Peru"
 ],
 [
   "code": "PHL",
   "country": "Philippines"
 ],
 [
   "code": "POL",
   "country": "Poland"
 ],
 [
   "code": "PRT",
   "country": "Portugal"
 ],
 [
   "code": "PRI",
   "country": "Puerto Rico"
 ],
 [
   "code": "QAT",
   "country": "Qatar"
 ],
 [
   "code": "ROU",
   "country": "Romania"
 ],
 [
   "code": "RUS",
   "country": "Russia"
 ],
 [
   "code": "RWA",
   "country": "Rwanda"
 ],
 [
   "code": "KNA",
   "country": "Saint Kitts and Nevis"
 ],
 [
   "code": "LCA",
   "country": "Saint Lucia"
 ],
 [
   "code": "VCT",
   "country": "Saint Vincent and the Grenadines"
 ],
 [
   "code": "SMR",
   "country": "San Marino"
 ],
 [
   "code": "STP",
   "country": "Sao Tome and Principe"
 ],
 [
   "code": "SAU",
   "country": "Saudi Arabia"
 ],
 [
   "code": "SEN",
   "country": "Senegal"
 ],
 [
   "code": "SRB",
   "country": "Serbia"
 ],
 [
   "code": "SYC",
   "country": "Seychelles"
 ],
 [
   "code": "SLE",
   "country": "Sierra Leone"
 ],
 [
   "code": "SGP",
   "country": "Singapore"
 ],
 [
   "code": "SXM",
   "country": "Sint Maarten (Dutch part)"
 ],
 [
   "code": "SVK",
   "country": "Slovakia"
 ],
 [
   "code": "SVN",
   "country": "Slovenia"
 ],
 [
   "code": "SOM",
   "country": "Somalia"
 ],
 [
   "code": "ZAF",
   "country": "South Africa"
 ],
 [
   "code": "KOR",
   "country": "South Korea"
 ],
 [
   "code": "SSD",
   "country": "South Sudan"
 ],
 [
   "code": "ESP",
   "country": "Spain"
 ],
 [
   "code": "LKA",
   "country": "Sri Lanka"
 ],
 [
   "code": "SDN",
   "country": "Sudan"
 ],
 [
   "code": "SUR",
   "country": "Suriname"
 ],
 [
   "code": "SWZ",
   "country": "Swaziland"
 ],
 [
   "code": "SWE",
   "country": "Sweden"
 ],
 [
   "code": "CHE",
   "country": "Switzerland"
 ],
 [
   "code": "SYR",
   "country": "Syria"
 ],
 [
   "code": "TWN",
   "country": "Taiwan"
 ],
 [
   "code": "TJK",
   "country": "Tajikistan"
 ],
 [
   "code": "TZA",
   "country": "Tanzania"
 ],
 [
   "code": "THA",
   "country": "Thailand"
 ],
 [
   "code": "TLS",
   "country": "Timor"
 ],
 [
   "code": "TGO",
   "country": "Togo"
 ],
 [
   "code": "TTO",
   "country": "Trinidad and Tobago"
 ],
 [
   "code": "TUN",
   "country": "Tunisia"
 ],
 [
   "code": "TUR",
   "country": "Turkey"
 ],
 [
   "code": "TCA",
   "country": "Turks and Caicos Islands"
 ],
 [
   "code": "UGA",
   "country": "Uganda"
 ],
 [
   "code": "UKR",
   "country": "Ukraine"
 ],
 [
   "code": "ARE",
   "country": "United Arab Emirates"
 ],
 [
   "code": "GBR",
   "country": "United Kingdom"
 ],
 [
   "code": "USA",
   "country": "United States"
 ],
 [
   "code": "VIR",
   "country": "United States Virgin Islands"
 ],
 [
   "code": "URY",
   "country": "Uruguay"
 ],
 [
   "code": "UZB",
   "country": "Uzbekistan"
 ],
 [
   "code": "VAT",
   "country": "Vatican"
 ],
 [
   "code": "VEN",
   "country": "Venezuela"
 ],
 [
   "code": "VNM",
   "country": "Vietnam"
 ],
 [
   "code": "ESH",
   "country": "Western Sahara"
 ],
 [
   "code": "YEM",
   "country": "Yemen"
 ],
 [
   "code": "ZMB",
   "country": "Zambia"
 ],
 [
   "code": "ZWE",
   "country": "Zimbabwe"
 ]
]
