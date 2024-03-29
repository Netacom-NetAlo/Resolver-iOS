//
//  ResolverInjectedTests.swift
//  ResolverTests
//
//  Created by Michael Long on 3/30/18.
//  Copyright © 2018 com.hmlong. All rights reserved.
//

import XCTest
@testable import Resolver

#if swift(>=5.1)

class BasicInjectedViewController {
    @Injected var service: XYZService
}

class NamedInjectedViewController {
    @Injected(name: "fred") var service: XYZNameService
}

class NamedInjectedViewController2 {
    @Injected(name: "barney") var service: XYZNameService
}

extension MyResolver {
    static var custom = MyResolver()
}

class ContainerInjectedViewController {
    @Injected(container: .custom) var service: XYZNameService
}

class LazyInjectedViewController {
    @LazyInjected var service: XYZService
}

class LazyInjectedArgumentsViewController {
    @LazyInjected var service: XYZArgumentService
    init() {
        $service.args = ["condition": true, "string": "betty"]
    }
}

class WeakLazyInjectedParentViewController {
    @Injected var strongService: WeakXYZService
}

class WeakLazyInjectedChildViewController {
    @WeakLazyInjected var weakService: WeakXYZService?
}

class OptionalInjectedViewController {
    @OptionalInjected var service: XYZService?
    @OptionalInjected var notRegistered: NotRegistered?
}

protocol ReturnsSomthing: AnyObject {
    func returnSomething() -> Bool
}

class WeakXYZService: XYZService, ReturnsSomthing {
    func returnSomething() -> Bool {
        return true
    }
}

class WeakLazyInjectedProtocolViewController {
    @WeakLazyInjected var service: ReturnsSomthing?
}

class NotRegistered {
}

class ResolverInjectedTests: XCTestCase {

    override func setUp() {
        super.setUp()

        MyResolver.main.register { WeakXYZService(nil) }
            .implements(ReturnsSomthing.self)
            .scope(.shared)

        MyResolver.main.register { XYZSessionService() }
        MyResolver.main.register { XYZService(MyResolver.main.optional()) }

        MyResolver.main.register(name: "fred") { XYZNameService("fred") }
        MyResolver.main.register(name: "barney") { XYZNameService("barney") }

        MyResolver.main.register { (_, args) in
            XYZArgumentService(condition: args("condition"), string: args("string"))
        }
        
        MyResolver.custom.register { XYZNameService("custom") }
    }

    override func tearDown() {
        super.tearDown()
    }

    func testBasicInjection() {
        let vc = BasicInjectedViewController()
        XCTAssertNotNil(vc.service)
        XCTAssertNotNil(vc.service.session)
    }

    func testNamedInjection1() {
        let vc = NamedInjectedViewController()
        XCTAssertNotNil(vc.service)
        XCTAssert(vc.service.name == "fred")
    }

    func testNamedInjection2() {
        let vc = NamedInjectedViewController2()
        XCTAssertNotNil(vc.service)
        XCTAssert(vc.service.name == "barney")
    }

    func testContainerInjection() {
        let vc = ContainerInjectedViewController()
        XCTAssertNotNil(vc.service)
        XCTAssert(vc.service.name == "custom")
    }

    func testLazyInjection() {
        let vc = LazyInjectedViewController()
        XCTAssert(vc.$service.isEmpty)
        XCTAssertNotNil(vc.service)
        XCTAssertNotNil(vc.service.session)
        XCTAssert(!vc.$service.isEmpty)
    }

    func testLazyInjectionArguments() {
        let vc = LazyInjectedArgumentsViewController()
        XCTAssert(vc.$service.isEmpty)
        XCTAssertNotNil(vc.service)
        XCTAssert(vc.service.condition == true)
        XCTAssert(vc.service.string == "betty")
    }

    func testParentChildWeakLazyInjectedViewController() {
        var parent: WeakLazyInjectedParentViewController? = WeakLazyInjectedParentViewController()
        XCTAssertNotNil(parent?.strongService)

        let child = WeakLazyInjectedChildViewController()
        XCTAssert(child.$weakService.isEmpty == true)
        XCTAssert(child.weakService?.returnSomething() == true)
        XCTAssertNotNil(child.weakService)
        XCTAssert(child.$weakService.isEmpty == false)

        parent = nil
        XCTAssert(child.$weakService.isEmpty == true)
        XCTAssertNil(parent?.strongService)
        XCTAssertNil(child.weakService)
    }

    func testWeakLazyInjectedProtocolViewController() {
        let parent: WeakLazyInjectedParentViewController? = WeakLazyInjectedParentViewController()
        XCTAssertNotNil(parent?.strongService)

        let child = WeakLazyInjectedProtocolViewController()
        XCTAssert(child.service?.returnSomething() == true)
        XCTAssertNotNil(child.service)
    }

    func testOptionalInjection() {
        let vc = OptionalInjectedViewController()
        XCTAssertNotNil(vc.service)
        XCTAssertNil(vc.notRegistered)
        vc.service = nil
        XCTAssertNil(vc.service)
    }
}

#endif
