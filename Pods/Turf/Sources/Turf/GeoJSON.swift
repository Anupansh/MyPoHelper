import Foundation
#if !os(Linux)
import CoreLocation
#endif

/**
 A [GeoJSON object](https://datatracker.ietf.org/doc/html/rfc7946#section-3) represents a Geometry, Feature, or collection of
 Features.
 */
public enum GeoJSONObject: Equatable {
    /**
     A [Geometry object](https://datatracker.ietf.org/doc/html/rfc7946#section-3.1) represents points, curves, and surfaces in coordinate space.
     
     - parameter geometry: The GeoJSON object as a Geometry object.
     */
    case geometry(_ geometry: Geometry)
    
    /**
     A [Feature object](https://datatracker.ietf.org/doc/html/rfc7946#section-3.2) represents a spatially bounded thing.
     
     - parameter feature: The GeoJSON object as a Feature object.
     */
    case feature(_ feature: Feature)
    
    /**
     A [FeatureCollection object](https://datatracker.ietf.org/doc/html/rfc7946#section-3.3) is a collection of Feature objects.
     
     - parameter featureCollection: The GeoJSON object as a FeatureCollection object.
     */
    case featureCollection(_ featureCollection: FeatureCollection)
    
    /// Initializes a GeoJSON object representing the given GeoJSON object–convertible instance.
    public init(_ object: GeoJSONObjectConvertible) {
        self = object.geoJSONObject
    }
}

extension GeoJSONObject: Codable {
    private enum CodingKeys: String, CodingKey {
        case kind = "type"
    }
    
    public init(from decoder: Decoder) throws {
        let kindContainer = try decoder.container(keyedBy: CodingKeys.self)
        let container = try decoder.singleValueContainer()
        switch try kindContainer.decode(String.self, forKey: .kind) {
        case Feature.Kind.Feature.rawValue:
            self = .feature(try container.decode(Feature.self))
        case FeatureCollection.Kind.FeatureCollection.rawValue:
            self = .featureCollection(try container.decode(FeatureCollection.self))
        default:
            self = .geometry(try container.decode(Geometry.self))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .geometry(let geometry):
            try container.encode(geometry)
        case .feature(let feature):
            try container.encode(feature)
        case .featureCollection(let featureCollection):
            try container.encode(featureCollection)
        }
    }
}

/**
 A type that can be represented as a `GeoJSONObject` instance.
 */
public protocol GeoJSONObjectConvertible {
    /// The instance wrapped in a `GeoJSONObject` instance.
    var geoJSONObject: GeoJSONObject { get }
}

extension GeoJSONObject: GeoJSONObjectConvertible {
    public var geoJSONObject: GeoJSONObject { return self }
}

extension Geometry: GeoJSONObjectConvertible {
    public var geoJSONObject: GeoJSONObject { return .geometry(self) }
}

extension Feature: GeoJSONObjectConvertible {
    public var geoJSONObject: GeoJSONObject { return .feature(self) }
}

extension FeatureCollection: GeoJSONObjectConvertible {
    public var geoJSONObject: GeoJSONObject { return .featureCollection(self) }
}
