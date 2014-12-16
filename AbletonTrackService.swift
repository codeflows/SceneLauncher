import ReactiveCocoa

class AbletonTrackService : TrackService {
    class Person: NSObject {
        var name = "John Doe"
        
        override init() {
            super.init()
        }
    }
    
    func listTracks() -> [String] {
        let person = Person()
        let nameChanged = person.rac_valuesForKeyPath("name", observer: person)
        
        nameChanged.subscribeNext { (name) -> Void in
            println("Person's new name is \(name)")
        }
        
        person.setValue("Jari", forKey: "name")
        
        return ["Boom", "Boom", "Boom"]
    }
}