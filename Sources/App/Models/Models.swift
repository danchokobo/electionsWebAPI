//
//  Models.swift
//  App
//
//  Created by Danagul Otel on 12/18/18.
//


import Cocoa
import Vapor

final class BlockchainNode :Content {
    
    var address :String
    
    init(address :String) {
        self.address = address
    }
    
}

final class Election : Content {
    
    var voter :String
    var candidate :String
    
    init(voter :String, candidate :String) {
        self.voter = voter
        self.candidate = candidate
    }
}

final class Block : Content  {
    
    var index :Int = 0
    var previousHash :String = ""
    var hash :String!
    var nonce :Int
    
    private (set) var elections :[Election] = [Election]()
    
    var key :String {
        get {
            
            let electionsData = try! JSONEncoder().encode(self.elections)
            let electionsJSONString = String(data: electionsData, encoding: .utf8)
            
            return String(self.index) + self.previousHash + String(self.nonce) + electionsJSONString!
        }
    }
    
    func addTransaction(election :Election) {
        self.elections.append(election)
    }
    
    init() {
        self.nonce = 0
    }
    
}

final class Blockchain : Content  {
    
    private (set) var blocks = [Block]()
    private (set) var nodes = [BlockchainNode]()
    
    init(genesisBlock :Block) {
        addBlock(genesisBlock)
    }
    
    func registerNodes(nodes :[BlockchainNode]) -> [BlockchainNode] {
        self.nodes.append(contentsOf: nodes)
        return self.nodes
    }
    
    func addBlock(_ block :Block) {
        
        if self.blocks.isEmpty {
            block.previousHash = "0000000000000000"
            block.hash = generateHash(for :block)
        }
        
        self.blocks.append(block)
    }
    
    func getNextBlock(elections :[Election]) -> Block {
        
        let block = Block()
        elections.forEach { election in
            block.addTransaction(election: election)
        }
        
        let previousBlock = getPreviousBlock()
        block.index = self.blocks.count
        block.previousHash = previousBlock.hash
        block.hash = generateHash(for: block)
        return block
        
    }
    
    private func getPreviousBlock() -> Block {
        return self.blocks[self.blocks.count - 1]
    }
    
    func generateHash(for block :Block) -> String {
        
        var hash = block.key.sha1Hash()
        
        while(!hash.hasPrefix("00")) {
            block.nonce += 1
            hash = block.key.sha1Hash()
            print(hash)
        }
        
        return hash
    }
    
}

// String Extension
extension String {
    
    func sha1Hash() -> String {
        
        let task = Process()
        task.launchPath = "/usr/bin/shasum"
        task.arguments = []
        
        let inputPipe = Pipe()
        
        inputPipe.fileHandleForWriting.write(self.data(using: String.Encoding.utf8)!)
        
        inputPipe.fileHandleForWriting.closeFile()
        
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardInput = inputPipe
        task.launch()
        
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let hash = String(data: data, encoding: String.Encoding.utf8)!
        return hash.replacingOccurrences(of: "  -\n", with: "")
    }
}















