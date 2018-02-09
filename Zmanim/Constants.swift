//
//  Constants.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let Shacharis = "Shacharis"
    static let Mincha = "Mincha"
    static let Maariv = "Ma'ariv"
    
    struct Main {
        static let TableViewHeaderViewHeight: CGFloat = 250
        static let MapLaunchTransitionDuration: TimeInterval = 0.6
        static let MapDismissTransitionDuration: TimeInterval = 0.3
    }
    
    struct Zmanim {
        static let TableViewRowHeight: CGFloat = 52
        static let CellFontSize: CGFloat = 20
        
        struct ZmanTableViewCell {
            struct Alerts {
                struct Notify {
                    static let NotifyMe = "Notify Me.."
                    static let CancelAll = "Cancel All"
                }
                struct CantNotify {
                    static let Title = "Can't Notify"
                    static let Message = "Sorry, notification's are no longer available for this minyan"
                }
            }
        }
    }
    
    struct Location {
        static let TableViewHeaderViewHeight: CGFloat = 250
    }
    
    struct LocalZmanim {
        static let Title = "Local Zmanim"
        static let TableViewRowHeight: CGFloat = 52
        static let CellFontSize: CGFloat = 18
    }
    
    struct About {
        static let DefaultCellHeight: CGFloat = 44
        static let ImageCellHeight: CGFloat = 140
        static let FooterTextSize: CGFloat = 14
        static let FooterHeight: CGFloat = 50
        static let Title = "Zmanim for YU"
        static let Version = "Version"
        static let Website = "Website"
        static let ContactUs = "Contact Us"
        static let RateUs = "Rate Us On the App Store"
        static let Footer = "Copyright © 2016 Natanel Niazoff.\n All rights reserved."
        static let VerisonInfoDictionaryKey = "CFBundleShortVersionString"
    }
    
    struct Map {
        static let AnnotationViewReuseIdentifier = "Annotation View"
        struct Center {
            static let Latitude = 40.8507522
            static let Longitude = -73.931190
        }
        
        struct Distance {
            static let Latitude = 6000.0
            static let Longitude = 6000.0
        }
        
        struct Annotations {
            struct Ads {
                struct OneStop {
                    static let Title = "One Stop Kosher"
                    static let Latitude = 40.8515485
                    static let Longitude = -73.9281345
                }
            }
        }
        
        struct Callout {
            static let ViewLess = "View Less"
            static let ViewMore = "View More"
        }
    }
    
    struct Storyboard {
        static let CellReuseIdentifier = "Cell"
        
        struct Main {
            static let PresentMapSegueIdentifier = "Present Map"
            static let ShowZmanimSegueIdentifier = "Show Zmanim"
            static let ShowLocalZmanimSegueIdentifier = "Show Local Zmanim"
            static let ShowAboutSegueIdentifier = "Show About"
            static let ShowSelichosSegueIdentifier = "Show Selichos"
        }
        
        struct Zmanim {
            static let ZmanCellReuseIdentifier = "Zman Cell"
            static let ShowLocationSegueIdentifier = "Show Location"
            static let ReturnMainSegueIdentifier = "Return Main"
        }
        
        struct Location {
            static let DescriptionCellReuseIdentifier = "Description Cell"
            static let SubtitleCellReuseIdentifier = "Subtitle Cell"
        }
        
        struct About {
            static let ImageCellIdentifier = "Image Cell"
            static let TextCellIdentifier = "Text Cell"
            static let ButtonCellIdentifier = "Button Cell"
        }
    }
    
    struct Alerts {
        struct Main {
            struct MoreOptions {
                static let ShabbosLastUpdateMessage = "Shabbos Updated:"
                static let Shabbos = "Shabbos"
                static let LocalZmanim = "Local Zmanim"
                static let About = "About"
                static let Sponsor = "Sponsor"
            }
            
            struct Shabbos {
                static let Title = "Shabbos"
                static let Message = "Shabbos zmanim are available in the \"More\" section."
            }
        }
        
        struct Zmanim {
            struct NoZmanim {
                static let TextSize: CGFloat = 26
                static let Title = "No Zmanim"
            }
        }
        
        struct Location {
            struct Error {
                struct Image {
                    static let Message = "Error loading image. Try again later."
                }
            }
            
            struct Navigation {
                static let MapsActionTitle = "Maps"
                static let WazeActionTitle = "Waze"
                static let GoogleMapsActionTitle = "Google Maps"
            }
        }
        
        struct UnknownLocation {
                static let Title = "Unknown Location"
                static let Message = "This location is not available in YU Zmanim's database"
            }
        
        struct Error {
            static let Title = "Error"
            static let Message = "Oops! An error occured. Please try again later."
            
            struct Network {
                static let TitleSize: CGFloat = 26
                static let MessageSize: CGFloat = 18
                static let Title = "Not Connected to Internet"
                static let Message = "This page can't be displayed offline. Please connect and try again."
                static let MessagePullDown = "This page can't be displayed offline. Please connect and try again by pulling down."
            }
        }
        
        struct Actions {
            static let OK = "OK"
            static let Open = "Open"
            static let Cancel = "Cancel"
        }
    }

    struct URLs {
        static let YUStudentLife = "http://www.yu.edu/student-life"
        static let ZmanimWebsite = "http://zmanimforyu.weebly.com"
        static let ZmanimAppStore = "itms-apps://itunes.apple.com/app/id1071006216"
        
        struct YUZmanim {
            static let Shabbos = "http://www.yuzmanim.com/shabbos"
        }
        
        struct Ads {
            struct OneStop {
                static let Facebook = "https://www.facebook.com/onestopkosher"
                static let Instagram = "https://www.instagram.com/onestopkosher"
            }
        }
    }
    
    struct Assets {
        struct Images {
            static let TitleIcon = "Title Icon"
            static let YU = "YU.jpg"
            static let BellFull = "Bell Full"
            static let BellOutline = "Bell Outline"
            static let OneStopBanner = "One Stop Banner"
            static let OneStopMap = "One Stop Map"
        }
    }
    
    struct Animations {
        struct Location {
            struct NoZmanimLabel {
                static let Duration: TimeInterval = 0.75
                static let Delay: TimeInterval = 0.2
                static let Damping: CGFloat = 0.35
                static let Velocity: CGFloat = 0.5
            }
        }
    }
    
    struct ErrorCodes {
        static let NoNetwork = -1009
    }
}
