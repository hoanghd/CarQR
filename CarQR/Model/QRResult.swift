import Foundation

enum QRType {
    case standard
    case light
    case unknown
}

class QRResult {
    fileprivate var scannedTexts: [String] = []
    fileprivate var type: QRType = .unknown
    fileprivate var qr2: [String] = []
    fileprivate var qr3: [String] = []
    
    func setTexts(_ texts: [String]){
        reset()
        
        scannedTexts = texts
        process()
    }
    
    fileprivate func reset() {
        scannedTexts.removeAll()
        type = .unknown
        qr2.removeAll()
        qr3.removeAll()
    }
    
    fileprivate func process() {
        var part1: [String] = []
        var part2: [String] = []
        
        if scannedTexts.count >= 5 { //Standard
            for text in scannedTexts {
                if ( part1.count == 0 && !text.starts(with: "2/") ) || ( part1.count + part2.count ) >= 5 {
                    continue
                }
                
                if text.starts(with: "2/") {
                    part1.count == 0 ? part1.append(text) : part2.append(text)
                } else {
                    part2.count > 0 ? part2.append(text) : part1.append(text)
                }
            }
            
            if ( part1.count + part2.count ) != 5 {
                return
            }
            
            type = .standard
            
            if part1.count != 2 {
                (part1, part2) = (part2, part1)
            }
            
            (qr2, qr3) = ( part1.joined().components(separatedBy: "/"), part2.joined().components(separatedBy: "/") )
            
        } else { //Light
            for text in scannedTexts {
                if !text.starts(with: "K/") || ( part1.count>=1 && part2.count >= 1) {
                    continue
                }
                
                part1.count == 0 ? part1.append(text) : part2.append(text)
            }
            
            if part1.count == 0 || part2.count == 0{
                return
            }
            
            type = .light
            
            (qr2, qr3) = ( part1.joined().components(separatedBy: "/"), part2.joined().components(separatedBy: "/") )
            
            if qr2.count != 7 {
                (qr2, qr3) = (qr3, qr2)
            }
        }
    }
    
    func validate() -> Bool{
        switch type {
        case .standard:
            if  qr2.count    < 2 ||
                qr2[1].canBeConverted(to: String.Encoding.ascii) == true ||
                qr3.count    < 5 ||
                qr3[1].count != 3 ||
                qr3[3].count != 6 ||
                qr3[4].count != 4
            {
                return false
            }
            
        case .light:
            if qr2.count != 7 || qr3.count != 19 {
                return false
            }
            
            guard let ver2 = Int(qr2[1]), ver2 >= 22 else { return false }
            guard let ver3 = Int(qr3[1]), ver3 >= 31 else { return false }
            
        case .unknown:
            return false
        }
        
        return true
    }
    
    func getCertificate() -> CarInspectionCertificate? {
        switch type {
            case .standard:
                if let certificate = StandardCarInspectionCertificate(rawStrings: [qr2.joined(separator: "/"), qr3.joined(separator: "/") ]){
                    return CarInspectionCertificate.Standard( certificate )
                }
            case .light:
                if let certificate = LightCarInspectionCertificate(rawStrings: [qr2.joined(separator: "/"), qr3.joined(separator: "/") ]){
                    return CarInspectionCertificate.Light( certificate )
                }
            case .unknown:
                return nil
        }
    
        return nil
    }
    
    func debug(){
        if type != .unknown {
            print("\n=================")
            print("- type: \(type)")
            print(getCertificate() as Any)
        }
    }
}
