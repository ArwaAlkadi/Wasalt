//
//  MetroData.swift
//  Wasalt
//
//  Created by Rana Alqubaly on 12/06/1447 AH.
//


import CoreLocation

struct MetroData {
    
    
    // MARK: - BLUE LINE (Line 1) — North ↔ South (Olaya)
    static let blueLineStations: [Station] = [
        Station(name: "station.sab".localized, order: 1,
                coordinate: .init(latitude: 24.82943980747947, longitude: 46.61843964843821), minutesToNext: 0),
        
        Station(name: "station.dr_sulaiman_al_habib".localized, order: 2,
                coordinate: .init(latitude: 24.81155379383345, longitude: 46.62654386725997), minutesToNext: 0),
        
        Station(name: "station.kafd".localized, order: 3,
                coordinate: .init(latitude: 24.76800392512061, longitude: 46.64364447641301), minutesToNext: 0),
        
        Station(name: "station.al_murooj".localized, order: 4,
                coordinate: .init(latitude: 24.75474607607529, longitude: 46.65422135694412), minutesToNext: 0),
        
        Station(name: "station.king_fahad_district".localized, order: 5,
                coordinate: .init(latitude: 24.74491442205136, longitude: 46.65932671648558), minutesToNext: 0),
        
        Station(name: "station.king_fahad_district_2".localized, order: 6,
                coordinate: .init(latitude: 24.73665171554253, longitude: 46.66338701990518), minutesToNext: 0),
        
        Station(name: "station.stc".localized, order: 7,
                coordinate: .init(latitude: 24.72679705304654, longitude: 46.66687987819414), minutesToNext: 0),
        
        Station(name: "station.al_wurud_2".localized, order: 8,
                coordinate: .init(latitude: 24.72172740595173, longitude: 46.67112888545265), minutesToNext: 0),
        
        Station(name: "station.al_urubah".localized, order: 9,
                coordinate: .init(latitude: 24.71321629407025, longitude: 46.67536633589778), minutesToNext: 0),
        
        Station(name: "station.alinma_bank".localized, order: 10,
                coordinate: .init(latitude: 24.70316648220116, longitude: 46.68032471057251), minutesToNext: 0),
        
        Station(name: "station.bank_albilad".localized, order: 11,
                coordinate: .init(latitude: 24.69650761170015, longitude: 46.68392634195393), minutesToNext: 0),
        
        Station(name: "station.king_fahad_library".localized, order: 12,
                coordinate: .init(latitude: 24.68969024261919, longitude: 46.6873653489969), minutesToNext: 0),
        
        Station(name: "station.al_murabba".localized, order: 12,
                coordinate: .init(latitude: 24.66485076093648, longitude: 46.70244592563306), minutesToNext: 0),
        
        Station(name: "station.ministry_of_interior".localized, order: 13,
                coordinate: .init(latitude: 24.67424257882058, longitude: 46.6950479643063), minutesToNext: 0),
        
        Station(name: "station.passport_department".localized, order: 15,
                coordinate: .init(latitude: 24.65956045632056, longitude: 46.70439494253413), minutesToNext: 0),
        
        Station(name: "station.national_museum".localized, order: 16,
                coordinate: .init(latitude: 24.64606261233078, longitude: 46.71416493164232), minutesToNext: 0),
        
        Station(name: "station.al_batha".localized, order: 17,
                coordinate: .init(latitude: 24.63793144884599, longitude: 46.71523382845812), minutesToNext: 0),
        
        Station(name: "station.qasr_al_hokm".localized, order: 18,
                coordinate: .init(latitude: 24.62858166288806, longitude: 46.71611888836972), minutesToNext: 0),
        
        Station(name: "station.al_oud".localized, order: 19,
                coordinate: .init(latitude: 24.62531899374494, longitude: 46.72101788739987), minutesToNext: 0),
        
        Station(name: "station.skirinah".localized, order: 20,
                coordinate: .init(latitude: 24.61755176745255, longitude: 46.72540678332071), minutesToNext: 0),
        
        Station(name: "station.manfouhah".localized, order: 21,
                coordinate: .init(latitude: 24.61045736735081, longitude: 46.72751741880297), minutesToNext: 0),
        
        Station(name: "station.al_iman_hospital".localized, order: 22,
                coordinate: .init(latitude: 24.60100804986984, longitude: 46.7352437098454), minutesToNext: 0),
        
        Station(name: "station.transportation_center".localized, order: 23,
                coordinate: .init(latitude: 24.59798690948253, longitude: 46.74514116213327), minutesToNext: 0),
        
        Station(name: "station.al_aziziah".localized, order: 24,
                coordinate: .init(latitude: 24.58613720640573, longitude: 46.76119639347265), minutesToNext: 0),
        
        Station(name: "station.ad_dar_al_baida".localized, order: 25,
                coordinate: .init(latitude: 24.55958910448547, longitude: 46.77654712393894), minutesToNext: 0),
        
    ]
    
    
    // MARK: - RED LINE (Line 2) — East ↔ West
    static let redLineStations: [Station] = [
        Station(name: "station.king_saud_university".localized, order: 0,
                coordinate: .init(latitude: 24.70967823253188, longitude: 46.62871099499831), minutesToNext: 0),
        
        Station(name: "station.king_salman_oasis".localized, order: 1,
                coordinate: .init(latitude: 24.71662928533406, longitude: 46.63877718460973), minutesToNext: 0),
        
        Station(name: "station.kacst".localized, order: 2,
                coordinate: .init(latitude: 24.72017061216426, longitude: 46.64693246597055), minutesToNext: 0),
        
        Station(name: "station.at_takhassussi".localized, order: 3,
                coordinate: .init(latitude: 24.72340744244227, longitude: 46.65464898678899), minutesToNext: 0),
        
        Station(name: "station.stc".localized, order: 4,
                coordinate: .init(latitude: 24.72655843698455, longitude: 46.66654513995131), minutesToNext: 0),
        
        Station(name: "station.al_wurud".localized, order: 5,
                coordinate: .init(latitude: 24.73304010012863, longitude: 46.67749338636222), minutesToNext: 0),
        
        Station(name: "station.king_abdulaziz_road".localized, order: 6,
                coordinate: .init(latitude: 24.73623884393125, longitude: 46.68521931745428), minutesToNext: 0),
        
        Station(name: "station.ministry_of_education".localized, order: 7,
                coordinate: .init(latitude: 24.7399774582299, longitude: 46.69346684713819), minutesToNext: 0),
        
        Station(name: "station.an_nuzhah".localized, order: 8,
                coordinate: .init(latitude: 24.74782156645681, longitude: 46.71311355644504), minutesToNext: 0),
        
        Station(name: "station.riyadh_exhibition_center".localized, order: 9,
                coordinate: .init(latitude: 24.75378482455737, longitude: 46.72721163892653), minutesToNext: 0),
        
        Station(name: "station.khalid_bin_alwaleed".localized, order: 10,
                coordinate: .init(latitude: 24.76705804271704, longitude: 46.75897415966957), minutesToNext: 0),
        
        Station(name: "station.al_hamra".localized, order: 11,
                coordinate: .init(latitude: 24.77642102227688, longitude: 46.77675786070972), minutesToNext: 0),
        
        Station(name: "station.al_khaleej".localized, order: 12,
                coordinate: .init(latitude: 24.78145044800828, longitude: 46.79447110643801), minutesToNext: 0),
        
        Station(name: "station.ishbiliyah".localized, order: 13,
                coordinate: .init(latitude: 24.79216004055396, longitude: 46.81106855810685), minutesToNext: 0),
        
        Station(name: "station.king_fahad_sport_city".localized, order: 14,
                coordinate: .init(latitude: 24.79243565532622, longitude: 46.83699440610236), minutesToNext: 0),
        
    ]
    
    
    // MARK: - ORANGE LINE (Line 3) — West ↔ East
    static let orangeLineStations: [Station] = [
        Station(name: "station.jeddah_road".localized, order: 0,
                coordinate: .init(latitude: 24.59121360322294, longitude: 46.54339421952785), minutesToNext: 0),
        
        Station(name: "station.tuwaiq".localized, order: 1,
                coordinate: .init(latitude: 24.58532648766099, longitude: 46.56190383360955), minutesToNext: 0),
        
        Station(name: "station.ad_douh".localized, order: 2,
                coordinate: .init(latitude: 24.58293167966869, longitude: 46.58806971836369), minutesToNext: 0),
        
        Station(name: "station.western_station".localized, order: 3,
                coordinate: .init(latitude: 24.58248496741372, longitude: 46.61438544942218), minutesToNext: 0),
        
        Station(name: "station.aishah_bint_abi_bakr".localized, order: 4,
                coordinate: .init(latitude: 24.60052873723215, longitude: 46.64374907224175), minutesToNext: 0),
        
        Station(name: "station.dhahrat_al_badiah".localized, order: 5,
                coordinate: .init(latitude: 24.6073754409049, longitude: 46.65497375326466), minutesToNext: 0),
        
        Station(name: "station.sultanah".localized, order: 6,
                coordinate: .init(latitude: 24.61481195473457, longitude: 46.6861039999333), minutesToNext: 0),
        
        Station(name: "station.al_jarradiyah".localized, order: 7,
                coordinate: .init(latitude: 24.61845741064425, longitude: 46.69821822387604), minutesToNext: 0),
        
        Station(name: "station.courts_complex".localized, order: 8,
                coordinate: .init(latitude: 24.62696585808965, longitude: 46.71242068810995), minutesToNext: 0),
        
        Station(name: "station.qasr_al_hokm".localized, order: 9,
                coordinate: .init(latitude: 24.62852568362789, longitude: 46.71605976865056), minutesToNext: 0),
        
        Station(name: "station.al_hilla".localized, order: 10,
                coordinate: .init(latitude: 24.63174974583536, longitude: 46.72092052341459), minutesToNext: 0),
        
        Station(name: "station.al_margab".localized, order: 11,
                coordinate: .init(latitude: 24.63402768715887, longitude: 46.72544371164624), minutesToNext: 0),
        
        Station(name: "station.as_salhiyah".localized, order: 12,
                coordinate: .init(latitude: 24.63722864945175, longitude: 46.73192914145916), minutesToNext: 0),
        
        Station(name: "station.first_industrial_city".localized, order: 13,
                coordinate: .init(latitude: 24.64518207915902, longitude: 46.73949283534146), minutesToNext: 0),
        
        Station(name: "station.railway".localized, order: 14,
                coordinate: .init(latitude: 24.64923336622137, longitude: 46.74124333488783), minutesToNext: 0),
        
        Station(name: "station.al_malaz".localized, order: 15,
                coordinate: .init(latitude: 24.66109427633321, longitude: 46.74505406619882), minutesToNext: 0),
        
        Station(name: "station.jarir_district".localized, order: 16,
                coordinate: .init(latitude: 24.67297035932004, longitude: 46.76052059417431), minutesToNext: 0),
        
        Station(name: "station.al_rajhi_mosque".localized, order: 17,
                coordinate: .init(latitude: 24.67971156503735, longitude: 46.77849737862974), minutesToNext: 0),
        
        Station(name: "station.harun_ar_rashid_road".localized, order: 18,
                coordinate: .init(latitude: 24.68608501392891, longitude: 46.79601710504106), minutesToNext: 0),
        
        Station(name: "station.an_naseem".localized, order: 19,
                coordinate: .init(latitude: 24.70026793259499, longitude: 46.82781400965195), minutesToNext: 0),
        
        Station(name: "station.hassan_bin_thabit".localized, order: 20,
                coordinate: .init(latitude: 24.71315305285557, longitude: 46.84810909256966), minutesToNext: 0),
        
        Station(name: "station.khashm_al_an".localized, order: 21,
                coordinate: .init(latitude: 24.72156579731185, longitude: 46.86032645729338), minutesToNext: 0),
    ]
    
    // MARK: - YELLOW LINE (Line 4) — Airport ↔ KAFD
    static let yellowLineStations: [Station] = [
        Station(name: "station.kafd".localized,        order: 8, coordinate: .init(latitude: 24.7671553, longitude: 46.6432711), minutesToNext: 5),
        Station(name: "station.ar_rabi".localized,     order: 7, coordinate: .init(latitude: 24.7862360, longitude: 46.6601248), minutesToNext: 5),
        Station(name: "station.uthman_bin_affan".localized, order: 6, coordinate: .init(latitude: 24.8013955, longitude: 46.6961421), minutesToNext: 4),
        Station(name: "station.sabic".localized,       order: 5, coordinate: .init(latitude: 24.8070691, longitude: 46.7095294), minutesToNext: 3),
        Station(name: "station.pnu1".localized,        order: 4, coordinate: .init(latitude: 24.8414744, longitude: 46.7174164), minutesToNext: 6),
        Station(name: "station.pnu2".localized,        order: 3, coordinate: .init(latitude: 24.8596218, longitude: 46.7045103), minutesToNext: 3),
        Station(name: "station.airport_t5".localized,  order: 2, coordinate: .init(latitude: 24.9407856, longitude: 46.7102385), minutesToNext: 11),
        Station(name: "station.airport_t3_4".localized, order: 1, coordinate: .init(latitude: 24.9560402, longitude: 46.7021429), minutesToNext: 3),
        Station(name: "station.airport_t1_2".localized, order: 0, coordinate: .init(latitude: 24.9609970, longitude: 46.6989819), minutesToNext: 3)
    ]
    
    // MARK: - GREEN LINE (Line 5) — Ministry ↔ Museum
    static let greenLineStations: [Station] = [
        Station(name: "station.national_museum".localized, order: 0,
                coordinate: .init(latitude: 24.64607279558212, longitude: 46.71427983670233), minutesToNext: 0),
        
        Station(name: "station.ministry_of_finance".localized, order: 1,
                coordinate: .init(latitude: 24.65127908328224, longitude: 46.71573060418663), minutesToNext: 0),
        
        Station(name: "station.king_abdulaziz_hospital".localized, order: 2,
                coordinate: .init(latitude: 24.65904589369298, longitude: 46.71727365226771), minutesToNext: 0),
        
        Station(name: "station.ministry_of_defense".localized, order: 3,
                coordinate: .init(latitude: 24.66712507970303, longitude: 46.71825678997175), minutesToNext: 0),
        
        Station(name: "station.al_wizarat".localized, order: 4,
                coordinate: .init(latitude: 24.67721661325981, longitude: 46.71835817336265), minutesToNext: 0),
        
        Station(name: "station.gosi".localized, order: 5,
                coordinate: .init(latitude: 24.686692275556, longitude: 46.71819918138066), minutesToNext: 0),
        
        Station(name: "station.officers_club".localized, order: 6,
                coordinate: .init(latitude: 24.69752283785252, longitude: 46.71802902980748), minutesToNext: 0),
        
        Station(name: "station.abu_dhabi_square".localized, order: 7,
                coordinate: .init(latitude: 24.70611607029804, longitude: 46.71634234922706), minutesToNext: 0),
        
        Station(name: "station.ad_dhabab".localized, order: 8,
                coordinate: .init(latitude: 24.70915859869369, longitude: 46.70835711021662), minutesToNext: 0),
        
        Station(name: "station.as_sulimaniyah".localized, order: 9,
                coordinate: .init(latitude: 24.7130431910079, longitude: 46.69954390840239), minutesToNext: 0),
        
        Station(name: "station.king_salman_park".localized, order: 10,
                coordinate: .init(latitude: 24.72833810456862, longitude: 46.7010605218833), minutesToNext: 0),
        
        Station(name: "station.ministry_of_education".localized, order: 11,
                coordinate: .init(latitude: 24.73977015479611, longitude: 46.69359791097942), minutesToNext: 0),
        
    ]
    
    
    // MARK: - PURPLE LINE (Line 6) — KAFD ↔ An Naseem
    static let purpleLineStations: [Station] = [
        Station(name: "station.kafd".localized, order: 0,
                coordinate: .init(latitude: 24.7681786337211, longitude: 46.64360617754577), minutesToNext: 0),
        
        Station(name: "station.ar_rabi".localized, order: 1,
                coordinate: .init(latitude: 24.78629157966825, longitude: 46.66057921262878), minutesToNext: 0),
        
        Station(name: "station.uthman_bin_affan".localized, order: 2,
                coordinate: .init(latitude: 24.80050291216557, longitude: 46.69634901482668), minutesToNext: 0),
        
        Station(name: "station.sabic".localized, order: 3,
                coordinate: .init(latitude: 24.80735674485716, longitude: 46.70959638581176), minutesToNext: 0),
        
        Station(name: "station.granadia".localized, order: 4,
                coordinate: .init(latitude: 24.78648327857564, longitude: 46.72933303753641), minutesToNext: 0),
        
        Station(name: "station.al_yarmuk".localized, order: 5,
                coordinate: .init(latitude: 24.79102722793817, longitude: 46.76642231187255), minutesToNext: 0),
        
        Station(name: "station.al_hamra".localized, order: 6,
                coordinate: .init(latitude: 24.77632719132187, longitude: 46.77657649147416), minutesToNext: 0),
        
        Station(name: "station.al_andalus".localized, order: 7,
                coordinate: .init(latitude: 24.75674689952316, longitude: 46.79050988521736), minutesToNext: 0),
        
        Station(name: "station.khurais_road".localized, order: 8,
                coordinate: .init(latitude: 24.73808432123275, longitude: 46.80009645445539), minutesToNext: 0),
        
        Station(name: "station.as_salam".localized, order: 9,
                coordinate: .init(latitude: 24.72219711748086, longitude: 46.8114455888186), minutesToNext: 0),
        
        Station(name: "station.an_naseem".localized, order: 10,
                coordinate: .init(latitude: 24.70048083828638, longitude: 46.82796281476497), minutesToNext: 0),
    ]
    
    
}

extension MetroData {

    /// All metro stations (unique by coordinate)
    static let allStations: [Station] = {
        let all = blueLineStations
            + redLineStations
            + orangeLineStations
            + yellowLineStations
            + greenLineStations
            + purpleLineStations

        // Remove duplicates (shared stations like KAFD, Qasr Al Hokm, etc.)
        var seen = Set<String>()
        return all.filter {
            let key = "\($0.coordinate.latitude),\($0.coordinate.longitude)"
            return seen.insert(key).inserted
        }
    }()
}
