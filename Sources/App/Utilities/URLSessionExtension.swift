import Vapor

extension URLSession {
    public func data(with request: URLRequest) throws -> (Data, HTTPURLResponse) {
        var error: Error?
        var result: (Data, HTTPURLResponse)?
        let semaphore = DispatchSemaphore(value: 0)

        self.dataTask(with: request) { data, response, innerError in
            if let data = data, let response = response as? HTTPURLResponse {
                result = (data, response)
            } else {
                error = innerError
            }
            semaphore.signal()
        }.resume()

        semaphore.wait()

        if let error = error {
            throw error
        } else if let result = result {
            return result
        } else {
            fatalError("Something went horribly wrong.")
        }
    }
}
