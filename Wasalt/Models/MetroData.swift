//
//  MetroData.swift
//  Wasalt
//
//  Created by Rana Alqubaly on 12/06/1447 AH.
//


import CoreLocation

struct MetroData {

    // MARK: - BLUE LINE (Line 1) — SAB ↔ Ad Dar Al Baida
    static let blueLineStations: [Station] = [
        Station(name: "station.sab".localized, order: 0,
                coordinate: .init(latitude: 24.8294892, longitude: 46.6165942),
                minutesToNext: 0, minutesToPrevious: nil,    //هلا رنا، هنا خليتها نيل لانها اخر محطة
                isTransferStation: false, transferLines: nil),

        Station(name: "station.dr_sulaiman_al_habib".localized, order: 1,
                coordinate: .init(latitude: 24.8115616, longitude: 46.6256353),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),
        
        Station(name: "station.kafd".localized, order: 2,
                coordinate: .init(latitude: 24.7674381, longitude: 46.6430760),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: true, transferLines: [.blue, .yellow, .purple]),

        Station(name: "station.al_murooj".localized, order: 3,
                coordinate: .init(latitude: 24.7548333, longitude: 46.6542511),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.king_fahad_district".localized, order: 4,
                coordinate: .init(latitude: 24.7454224, longitude: 46.6587931),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.king_fahad_district_2".localized, order: 5,
                coordinate: .init(latitude: 24.7366166, longitude: 46.6634822),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.stc".localized, order: 6,
                coordinate: .init(latitude: 24.7267275, longitude: 46.6667834),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: true, transferLines: [.blue, .red]),

        Station(name: "station.al_wurud_2".localized, order: 7,
                coordinate: .init(latitude: 24.7211994, longitude: 46.6713002),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.al_urubah".localized, order: 8,
                coordinate: .init(latitude: 24.7135078, longitude: 46.6751921),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.alinma_bank".localized, order: 9,
                coordinate: .init(latitude: 24.7034201, longitude: 46.6802403),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.bank_albilad".localized, order: 10,
                coordinate: .init(latitude: 24.6966829, longitude: 46.6836632),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.king_fahad_library".localized, order: 11,
                coordinate: .init(latitude: 24.6901775, longitude: 46.6871236),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.ministry_of_interior".localized, order: 12,
                coordinate: .init(latitude: 24.6743796, longitude: 46.6949301),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.al_murabba".localized, order: 13,
                coordinate: .init(latitude: 24.6648472, longitude: 46.7023277),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.passport_department".localized, order: 14,
                coordinate: .init(latitude: 24.6598316, longitude: 46.7042515),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.national_museum".localized, order: 15,
                coordinate: .init(latitude: 24.6453158, longitude: 46.7131497),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: true, transferLines: [.blue, .green]),

        Station(name: "station.al_batha".localized, order: 16,
                coordinate: .init(latitude: 24.6370036, longitude: 46.7147661),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.qasr_al_hokm".localized, order: 17,
                coordinate: .init(latitude: 24.6289426, longitude: 46.7162232),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: true, transferLines: [.blue, .orange]),

        Station(name: "station.al_oud".localized, order: 18,
                coordinate: .init(latitude: 24.6253102, longitude: 46.7210850),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.skirinah".localized, order: 19,
                coordinate: .init(latitude: 24.6178843, longitude: 46.7252723),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.manfouhah".localized, order: 20,
                coordinate: .init(latitude: 24.6105225, longitude: 46.7274885),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.al_iman_hospital".localized, order: 21,
                coordinate: .init(latitude: 24.6006423, longitude: 46.7357450),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.transportation_center".localized, order: 22,
                coordinate: .init(latitude: 24.5982715, longitude: 46.7451216),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.al_aziziah".localized, order: 23,
                coordinate: .init(latitude: 24.5873132, longitude: 46.7608250),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.ad_dar_al_baida".localized, order: 24,
                coordinate: .init(latitude: 24.5600775, longitude: 46.7763083),
                minutesToNext: nil, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),
    ]


    // MARK: - RED LINE (Line 2) — King Saud University ↔ King Fahad Sport City
    static let redLineStations: [Station] = [
        Station(name: "station.king_saud_university".localized, order: 0,
                coordinate: .init(latitude: 24.7102644, longitude: 46.6283594),
                minutesToNext: 0, minutesToPrevious: nil,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.king_salman_oasis".localized, order: 1,
                coordinate: .init(latitude: 24.7170252, longitude: 46.6385880),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.kacst".localized, order: 2,
                coordinate: .init(latitude: 24.7210679, longitude: 46.6481370),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.at_takhassussi".localized, order: 3,
                coordinate: .init(latitude: 24.7238578, longitude: 46.6547583),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.stc".localized, order: 4,
                coordinate: .init(latitude: 24.7267275, longitude: 46.6667834),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: true, transferLines: [.blue, .red]),

        Station(name: "station.al_wurud".localized, order: 5,
                coordinate: .init(latitude: 24.7333281, longitude: 46.6772014),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.king_abdulaziz_road".localized, order: 6,
                coordinate: .init(latitude: 24.7368504, longitude: 46.6854918),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.ministry_of_education".localized, order: 7,
                coordinate: .init(latitude: 24.7406872, longitude: 46.6946837),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: true, transferLines: [.red, .green]),

        Station(name: "station.an_nuzhah".localized, order: 8,
                coordinate: .init(latitude: 24.7481403, longitude: 46.7122988),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.riyadh_exhibition_center".localized, order: 9,
                coordinate: .init(latitude: 24.7545787, longitude: 46.7270764),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.khalid_bin_alwaleed".localized, order: 10,
                coordinate: .init(latitude: 24.7677609, longitude: 46.7591553),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.al_hamra".localized, order: 11,
                coordinate: .init(latitude: 24.7764208, longitude: 46.7767311),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: true, transferLines: [.red, .purple]),

        Station(name: "station.al_khaleej".localized, order: 12,
                coordinate: .init(latitude: 24.7820758, longitude: 46.7943036),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.ishbiliyah".localized, order: 13,
                coordinate: .init(latitude: 24.7924058, longitude: 46.8110111),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.king_fahad_sport_city".localized, order: 14,
                coordinate: .init(latitude: 24.7931832, longitude: 46.8365907),
                minutesToNext: nil, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),
    ]


    // MARK: - ORANGE LINE (Line 3) — Jeddah Road ↔ Khashm Al An
    static let orangeLineStations: [Station] = [
        Station(name: "station.jeddah_road".localized, order: 0,
                coordinate: .init(latitude: 24.5914765, longitude: 46.5435382),
                minutesToNext: 0, minutesToPrevious: nil,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.tuwaiq".localized, order: 1,
                coordinate: .init(latitude: 24.5854873, longitude: 46.5596781),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.ad_douh".localized, order: 2,
                coordinate: .init(latitude: 24.5826333, longitude: 46.5883321),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.western_station".localized, order: 3,
                coordinate: .init(latitude: 24.5817168, longitude: 46.6146935),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.aishah_bint_abi_bakr".localized, order: 4,
                coordinate: .init(latitude: 24.6006017, longitude: 46.6437740),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.dhahrat_al_badiah".localized, order: 5,
                coordinate: .init(latitude: 24.6067515, longitude: 46.6538269),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.sultanah".localized, order: 6,
                coordinate: .init(latitude: 24.6150154, longitude: 46.6868024),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.al_jarradiyah".localized, order: 7,
                coordinate: .init(latitude: 24.6183939, longitude: 46.6977672),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.courts_complex".localized, order: 8,
                coordinate: .init(latitude: 24.6268509, longitude: 46.7123477),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.qasr_al_hokm".localized, order: 9,
                coordinate: .init(latitude: 24.6289426, longitude: 46.7162232),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: true, transferLines: [.blue, .orange]),

        Station(name: "station.al_hilla".localized, order: 10,
                coordinate: .init(latitude: 24.6323194, longitude: 46.7218893),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.al_margab".localized, order: 11,
                coordinate: .init(latitude: 24.6345393, longitude: 46.7263492),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.as_salhiyah".localized, order: 12,
                coordinate: .init(latitude: 24.6378161, longitude: 46.7329400),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.first_industrial_city".localized, order: 13,
                coordinate: .init(latitude: 24.6453570, longitude: 46.7393757),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.railway".localized, order: 14,
                coordinate: .init(latitude: 24.6494724, longitude: 46.7406584),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.al_malaz".localized, order: 15,
                coordinate: .init(latitude: 24.6614548, longitude: 46.7448061),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.jarir_district".localized, order: 16,
                coordinate: .init(latitude: 24.6730759, longitude: 46.7603656),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.al_rajhi_mosque".localized, order: 17,
                coordinate: .init(latitude: 24.6802137, longitude: 46.7794170),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.harun_ar_rashid_road".localized, order: 18,
                coordinate: .init(latitude: 24.6860434, longitude: 46.7959629),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.an_naseem".localized, order: 19,
                coordinate: .init(latitude: 24.7004963, longitude: 46.8275389),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: true, transferLines: [.orange, .purple]),

        Station(name: "station.hassan_bin_thabit".localized, order: 20,
                coordinate: .init(latitude: 24.7127506, longitude: 46.8474663),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.khashm_al_an".localized, order: 21,
                coordinate: .init(latitude: 24.7212031, longitude: 46.8601378),
                minutesToNext: nil, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),
    ]


    // MARK: - YELLOW LINE (Line 4) — KAFD ↔ Airport
    static let yellowLineStations: [Station] = [
        Station(name: "station.kafd".localized, order: 0,
                coordinate: .init(latitude: 24.7674381, longitude: 46.6430760),
                minutesToNext: 5, minutesToPrevious: nil,
                isTransferStation: true, transferLines: [.blue, .yellow, .purple]),

        Station(name: "station.ar_rabi".localized, order: 1,
                coordinate: .init(latitude: 24.7862360, longitude: 46.6601248),
                minutesToNext: 6, minutesToPrevious: 5,
                isTransferStation: true, transferLines: [.yellow, .purple]),

        Station(name: "station.uthman_bin_affan".localized, order: 2,
                coordinate: .init(latitude: 24.8013955, longitude: 46.6961421),
                minutesToNext: 5, minutesToPrevious: 6,
                isTransferStation: true, transferLines: [.yellow, .purple]),

        Station(name: "station.sabic".localized, order: 3,
                coordinate: .init(latitude: 24.8070691, longitude: 46.7095294),
                minutesToNext: 6, minutesToPrevious: 5,
                isTransferStation: true, transferLines: [.yellow, .purple]),

        Station(name: "station.pnu1".localized, order: 4,
                coordinate: .init(latitude: 24.8414744, longitude: 46.7174164),
                minutesToNext: 4, minutesToPrevious: 6,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.pnu2".localized, order: 5,
                coordinate: .init(latitude: 24.8596218, longitude: 46.7045103),
                minutesToNext: 11, minutesToPrevious: 4,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.airport_t5".localized, order: 6,
                coordinate: .init(latitude: 24.9407856, longitude: 46.7102385),
                minutesToNext: 3, minutesToPrevious: 11,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.airport_t3_4".localized, order: 7,
                coordinate: .init(latitude: 24.9560402, longitude: 46.7021429),
                minutesToNext: 4, minutesToPrevious: 3,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.airport_t1_2".localized, order: 8,
                coordinate: .init(latitude: 24.9609970, longitude: 46.6989819),
                minutesToNext: nil, minutesToPrevious: 4,
                isTransferStation: false, transferLines: nil),
    ]


    // MARK: - GREEN LINE (Line 5) — National Museum ↔ Ministry of Education
    static let greenLineStations: [Station] = [
        Station(name: "station.national_museum".localized, order: 0,
                coordinate: .init(latitude: 24.6453158, longitude: 46.7131497),
                minutesToNext: 0, minutesToPrevious: nil,
                isTransferStation: true, transferLines: [.blue, .green]),

        Station(name: "station.ministry_of_finance".localized, order: 1,
                coordinate: .init(latitude: 24.6521704, longitude: 46.7163154),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.king_abdulaziz_hospital".localized, order: 2,
                coordinate: .init(latitude: 24.6597616, longitude: 46.7176853),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.ministry_of_defense".localized, order: 3,
                coordinate: .init(latitude: 24.6680400, longitude: 46.7182623),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.al_wizarat".localized, order: 4,
                coordinate: .init(latitude: 24.6760433, longitude: 46.7183820),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.gosi".localized, order: 5,
                coordinate: .init(latitude: 24.6863151, longitude: 46.7181547),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.officers_club".localized, order: 6,
                coordinate: .init(latitude: 24.6979507, longitude: 46.7179213),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.abu_dhabi_square".localized, order: 7,
                coordinate: .init(latitude: 24.7060682, longitude: 46.7163885),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.ad_dhabab".localized, order: 8,
                coordinate: .init(latitude: 24.7097658, longitude: 46.7075751),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.as_sulimaniyah".localized, order: 9,
                coordinate: .init(latitude: 24.7128210, longitude: 46.7003737),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.king_salman_park".localized, order: 10,
                coordinate: .init(latitude: 24.7282654, longitude: 46.7009353),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.ministry_of_education".localized, order: 11,
                coordinate: .init(latitude: 24.7406872, longitude: 46.6946837),
                minutesToNext: nil, minutesToPrevious: 0,
                isTransferStation: true, transferLines: [.red, .green]),
    ]


    // MARK: - PURPLE LINE (Line 6) — KAFD ↔ An Naseem
    static let purpleLineStations: [Station] = [
        Station(name: "station.kafd".localized, order: 0,
                coordinate: .init(latitude: 24.7674381, longitude: 46.6430760),
                minutesToNext: 0, minutesToPrevious: nil,
                isTransferStation: true, transferLines: [.blue, .yellow, .purple]),

        Station(name: "station.ar_rabi".localized, order: 1,
                coordinate: .init(latitude: 24.7862360, longitude: 46.6601248),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: true, transferLines: [.yellow, .purple]),

        Station(name: "station.uthman_bin_affan".localized, order: 2,
                coordinate: .init(latitude: 24.8013955, longitude: 46.6961421),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: true, transferLines: [.yellow, .purple]),

        Station(name: "station.sabic".localized, order: 3,
                coordinate: .init(latitude: 24.8070691, longitude: 46.7095294),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: true, transferLines: [.yellow, .purple]),

        Station(name: "station.granadia".localized, order: 4,
                coordinate: .init(latitude: 24.7864758, longitude: 46.7292490),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.al_yarmuk".localized, order: 5,
                coordinate: .init(latitude: 24.7912936, longitude: 46.7662913),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.al_hamra".localized, order: 6,
                coordinate: .init(latitude: 24.7764208, longitude: 46.7767311),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: true, transferLines: [.red, .purple]),

        Station(name: "station.al_andalus".localized, order: 7,
                coordinate: .init(latitude: 24.7567492, longitude: 46.7902096),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.khurais_road".localized, order: 8,
                coordinate: .init(latitude: 24.7407323, longitude: 46.7988037),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.as_salam".localized, order: 9,
                coordinate: .init(latitude: 24.7227764, longitude: 46.8111985),
                minutesToNext: 0, minutesToPrevious: 0,
                isTransferStation: false, transferLines: nil),

        Station(name: "station.an_naseem".localized, order: 10,
                coordinate: .init(latitude: 24.7004963, longitude: 46.8275389),
                minutesToNext: nil, minutesToPrevious: 0,
                isTransferStation: true, transferLines: [.orange, .purple]),
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

        /// Remove duplicates (shared stations like KAFD, Qasr Al Hokm, etc.)
        var seen = Set<String>()
        return all.filter {
            let key = "\($0.coordinate.latitude),\($0.coordinate.longitude)"
            return seen.insert(key).inserted
        }
    }()
}
