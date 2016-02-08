import UIKit
import CoreData

struct Woning {
    
    var id : Int = 0
    var straatnaam : String = ""
    var huisnummer : String = ""
    var plaats : String = ""
    var omschrijving : String = ""
    var kenmerken : String = ""
    var coordLat : Double = 0.0
    var coordLong : Double = 0.0
    var makelaarEmail : String = ""
    var makelaarTelefoon : String = ""
    var afbeeldingen : [JSON] = []
    var thumbnail : String = ""
    var prijs: Double = 0.0
    var oppervlakte : Double = 0.0
    var aantalKamers : Int = 0
    var like : Bool = false;
    
    init(json data: JSON) {
        id = data["Id"].int!
        straatnaam = data["Straatnaam"].string!
        huisnummer = data["Huisnummer"].string!
        plaats = data["Plaats"].string!
        omschrijving = data["Omschrijving"].string!
        kenmerken = data["Kenmerken"].string!
        coordLat = data["CoordLat"].double!
        coordLong = data["CoordLong"].double!
        makelaarEmail = data["MakelaarEmail"].string!
        makelaarTelefoon = data["MakelaarTelefoon"].string!
        afbeeldingen = data["Afbeeldingen"].array!
        thumbnail = data["Thumbnail"].string!
        prijs = data["Prijs"].double!
        oppervlakte = data["Oppervlakte"].double!
        aantalKamers = data["AantalKamers"].int!
    }
}