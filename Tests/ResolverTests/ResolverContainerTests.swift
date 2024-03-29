//
//  ResolverContainerTests.swift
//  ResolverTests
//
//  Created by Michael Long on 3/30/18.
//  Copyright © 2018 com.hmlong. All rights reserved.
//

import XCTest
@testable import Resolver

class ResolverContainerTests: XCTestCase {

    var resolver1: MyResolver!
    var resolver2: MyResolver!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testResolverDistinctContainers() {

        resolver1 = MyResolver()
        resolver2 = MyResolver()

        resolver1.register() { XYZNameService("Fred") }
        resolver2.register() { XYZNameService("Barney") }

        let fred: XYZNameService? = resolver1.optional()
        XCTAssertNotNil(fred)
        XCTAssert(fred?.name == "Fred")

        let barney: XYZNameService? = resolver2.optional()
        XCTAssertNotNil(barney)
        XCTAssert(barney?.name == "Barney")
    }

    func testResolverDistinctContainersRedux() {

        resolver1 = MyResolver()
        resolver2 = MyResolver()

        resolver1.register() { XYZNameService("Fred") }

        let fred: XYZNameService? = resolver1.optional()
        XCTAssertNotNil(fred)
        XCTAssert(fred?.name == "Fred")

        let noFred: XYZNameService? = resolver2.optional()
        XCTAssertNil(noFred)
    }

    func testResolverParentContainers() {

        resolver1 = MyResolver()
        resolver2 = MyResolver(parent: resolver1)

        resolver1.register() { XYZNameService("Resolver 1") }

        // should find in resolver in which it was defined
        let r1: XYZNameService? = resolver1.optional()
        XCTAssertNotNil(r1)
        XCTAssert(r1?.name == "Resolver 1")

        // child container should find in parent container
        let r2: XYZNameService? = resolver2.optional()
        XCTAssertNotNil(r2)
        XCTAssert(r2?.name == "Resolver 1")
    }

    func testResolverParentContainerOverride() {

        resolver1 = MyResolver()
        resolver2 = MyResolver(parent: resolver1)

        resolver1.register() { XYZNameService("Overridden") }
        resolver2.register() { XYZNameService("Resolved") }

        // should find in resolver in which it was defined
        let r1: XYZNameService? = resolver1.optional()
        XCTAssertNotNil(r1)
        XCTAssert(r1?.name == "Overridden")

        // should find new registration in parent container that overrides child container
        let r2: XYZNameService? = resolver2.optional()
        XCTAssertNotNil(r2)
        XCTAssert(r2?.name == "Resolved")
    }

    func testResolverParentOverrideSpecificNamedServices() {

        resolver1 = MyResolver()
        resolver2 = MyResolver(parent: resolver1)

        resolver1.register()             { XYZNameService("Unnamed service") }
        resolver1.register(name: "Name") { XYZNameService("Overriden named service") }
        resolver2.register(name: "Name") { XYZNameService("Resolved named service") }

        // should find in resolver in which it was defined
        let r1: XYZNameService? = resolver1.optional()
        XCTAssertNotNil(r1)
        XCTAssert(r1?.name == "Unnamed service")

        let r1Named: XYZNameService? = resolver1.optional(name: "Name")
        XCTAssertNotNil(r1Named)
        XCTAssert(r1Named?.name == "Overriden named service")

        // should resolve from child container
        let r2: XYZNameService? = resolver2.optional()
        XCTAssertNotNil(r2)
        XCTAssert(r2?.name == "Unnamed service")

        // should find new registration in parent container that overrides child container
        let r2Named: XYZNameService? = resolver2.optional(name: "Name")
        XCTAssertNotNil(r2Named)
        XCTAssert(r2Named?.name == "Resolved named service")
    }

    func testResolverParentOverrideSpecificUnnamedServices() {

        resolver1 = MyResolver()
        resolver2 = MyResolver(parent: resolver1)

        resolver1.register(name: "Name") { XYZNameService("Named service") }
        resolver1.register()             { XYZNameService("Overriden unnamed service") }
        resolver2.register()             { XYZNameService("Resolved unnamed service") }

        // should find in resolver in which it was defined
        let r1: XYZNameService? = resolver1.optional()
        XCTAssertNotNil(r1)
        XCTAssert(r1?.name == "Overriden unnamed service")

        let r1Named: XYZNameService? = resolver1.optional(name: "Name")
        XCTAssertNotNil(r1Named)
        XCTAssert(r1Named?.name == "Named service")

        // should find new registration in parent container that overrides child container
        let r2: XYZNameService? = resolver2.optional()
        XCTAssertNotNil(r2)
        XCTAssert(r2?.name == "Resolved unnamed service")

        // should resolve from child container
        let r2Named: XYZNameService? = resolver2.optional(name: "Name")
        XCTAssertNotNil(r2Named)
        XCTAssert(r2Named?.name == "Named service")
    }
}
