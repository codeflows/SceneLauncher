import ReactiveCocoa

class AbletonTrackService : TrackService {
    func listTracks() -> [String] {
        // Pseudo-implementation:
        //
        // To get number of scenes (maybe needed so that we know all scenes have arrived)
        // - send /live/scenes
        // - receive /live/scenes (int)
        //
        // To get names of all scenes
        // - send /live/name/scene
        // - receive series of /live/name/scene (int scene, string name)
        return ["Boom", "Boom", "Boom"]
    }
}