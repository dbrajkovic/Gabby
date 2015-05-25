//
//  Gab.swift
//  Gabby
//
//  Created by Dan Brajkovic on 5/6/15.
//  Copyright (c) 2015 Pragmatic Labs, LLC. All rights reserved.
//

import Foundation
import CoreData

class Gab: NSManagedObject {

    @NSManaged var text: String
    @NSManaged var username: String
    @NSManaged var createdAt: NSDate

}
