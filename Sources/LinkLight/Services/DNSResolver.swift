import Foundation

struct DNSResolver {
    static func canResolveHost(from endpoint: String) -> Bool {
        guard let host = URL(string: endpoint)?.host, host.isEmpty == false else { return false }

        if host.range(of: "^[0-9.]+$", options: .regularExpression) != nil {
            return true
        }

        var hints = addrinfo(
            ai_flags: AI_DEFAULT,
            ai_family: AF_UNSPEC,
            ai_socktype: SOCK_STREAM,
            ai_protocol: IPPROTO_TCP,
            ai_addrlen: 0,
            ai_canonname: nil,
            ai_addr: nil,
            ai_next: nil
        )

        var info: UnsafeMutablePointer<addrinfo>?
        let result = getaddrinfo(host, nil, &hints, &info)
        defer {
            if let info { freeaddrinfo(info) }
        }
        return result == 0
    }
}
