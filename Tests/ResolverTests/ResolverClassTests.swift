//
//  ResolverClassTests.swift
//  ResolverTests
//
//  Created by Michael Long on 3/30/18.
//  Copyright © 2018 com.hmlong. All rights reserved.
//

import XCTest
@testable import Resolver

class ResolverClassTests: XCTestCase {

    var resolver: MyResolver!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testRegistrationAndExplicitResolution() {
        let session: XYZSessionService? = MyResolver.resolve(XYZSessionService.self)
        XCTAssertNotNil(session)
    }

    func testRegistrationAndInferedResolution() {
        let session: XYZSessionService? = MyResolver.resolve() as XYZSessionService
        XCTAssertNotNil(session)
    }

    func testRegistrationAndOptionalResolution() {
        let session: XYZSessionService? = MyResolver.optional()
        XCTAssertNotNil(session)
    }

    func testRegistrationAndOptionalResolutionFailure() {
        let unknown: XYZNameService? = MyResolver.optional()
        XCTAssertNil(unknown)
    }

    func testRegistrationAndResolutionChain() {
        let service: XYZService? = MyResolver.optional()
        XCTAssertNotNil(service)
        XCTAssertNotNil(service?.session)
    }

    func testRegistrationOverwritting() {
        MyResolver.register() { XYZNameService("Fred") }
        MyResolver.register() { XYZNameService("Barney") }
        let service: XYZNameService? = MyResolver.optional()
        XCTAssertNotNil(service)
        XCTAssert(service?.name == "Barney")
    }

    func testRegistrationAndPassedResolver() {
        MyResolver.register { XYZSessionService() }
        MyResolver.register { (r) -> XYZService in
            return XYZService( r.optional() )
        }
        let service: XYZService? = MyResolver.optional()
        XCTAssertNotNil(service)
        XCTAssertNotNil(service?.session)
    }

   func testRegistrationAndResolutionProperties() {
        MyResolver.register(name: "Props") { XYZSessionService() }
            .resolveProperties { (r, s) in
                s.name = "updated"
        }
        let session: XYZSessionService? = MyResolver.optional(name: "Props")
        XCTAssertNotNil(session)
        XCTAssert(session?.name == "updated")
    }

    func testRegistrationAndResolutionArguments() {
        let service: XYZService? = MyResolver.optional(args: true)
        XCTAssertNotNil(service)
        XCTAssertNotNil(service?.session)
    }

    func testRegistrationAndResolutionResolve() {
        let service: XYZService = MyResolver.resolve()
        XCTAssertNotNil(service.session)
    }

    func testRegistrationAndResolutionResolveArgs() {
        let service: XYZService = MyResolver.resolve(args: true)
        XCTAssertNotNil(service.session)
    }

}

