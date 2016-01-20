// The MIT License (MIT)
//
// Copyright (c) 2014 Thomas Visser
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


import Foundation
import Result


extension Dictionary where Key: Hashable, Value: AsyncType, Value.Value: ResultType  {
    
    /// Turns a dictionary of key K and value `Future<T>`'s into a future with a dictionary of key K and value T's (Future<[K: T]>)
    /// If one of the futures in the given sequence fails, the returned future will fail
    /// with the error of the first future that comes first in the value list.
    public func sequence() -> Future<[Key: Value.Value.Value], Value.Value.Error> {
        return traverse(ImmediateExecutionContext) {
            let key: Key = $0.0
            // this is not nice at all, but I've been unable to solve it in a better way without crashing the compiler
            let future = $0.1 as! Future<Value.Value.Value, Value.Value.Error>
            
            return future.map { (value: Value.Value.Value) in
                return (key, value)
            }
        }.map { (tuples: [(Key, Value.Value.Value)]) -> [Key: Value.Value.Value] in
            return Dictionary<Key, Value.Value.Value>(tuples)
        }
    }

}

private extension Dictionary {

    private init(_ elements: [Element]) {
        self.init()
        for (k, v) in elements {
            self[k] = v
        }
    }
}
