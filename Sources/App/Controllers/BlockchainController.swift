//
//  BlockchainController.swift
//  App
//
//  Created by Danagul Otel on 12/18/18.
//

import Foundation
import Vapor

class BlockchainController {
    
    private (set) var blockchainService :BlockchainService
    
    init() {
        self.blockchainService = BlockchainService()
    }
    
    func resolve(req :Request) -> Future<Blockchain> {
        
        let promise :EventLoopPromise<Blockchain> = req.eventLoop.newPromise()
        blockchainService.resolve {
            promise.succeed(result: $0)
        }
        
        return promise.futureResult
    }
    
    func getNodes(req :Request) -> [BlockchainNode] {
        return self.blockchainService.getNodes()
    }
    
    func registerNodes(req :Request, nodes :[BlockchainNode]) -> [BlockchainNode] {
        return self.blockchainService.registerNodes(nodes :nodes)
    }
    
    func mine(req :Request, election :Election) -> Block {
        return self.blockchainService.getNextBlock(elections :[election])
    }
    
    func getBlockchain(req :Request) -> Blockchain {
        return self.blockchainService.getBlockchain()
    }
    
    func greet(req :Request) -> Future<String> {
        
        return Future.map(on: req) { () -> String in
            return "Welcome to Blockchain"
        }
        
    }
    
}
