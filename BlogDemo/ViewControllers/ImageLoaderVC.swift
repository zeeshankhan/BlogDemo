import UIKit

protocol NetworkCancellable {
    func cancel()
    var isRunning: Bool { get }
}
extension URLSessionDataTask: NetworkCancellable {
    var isRunning: Bool {
        state == .running
    }
}

protocol NetworkService {
    func fetch(_ url: URL, completion: @escaping ((Result<Data, Error>)->())) -> NetworkCancellable
}

enum MyError: Error {
    case other
}

extension URLSession: NetworkService {
    func fetch(_ url: URL, completion: @escaping ((Result<Data, Error>)->())) -> NetworkCancellable {
        let task = dataTask(with: URLRequest(url: url)) { data, _, error in
            if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(error ?? MyError.other))
            }
        }
        task.resume()
        return task
    }
}

class DataFetcher {
    typealias Completion = (Data?) -> Void

    private let networkService: NetworkService
    private var cache = NSCache<NSURL, NSData>()
    private var runningRequests = [URL: NetworkCancellable]()
    private var loadingResponses = [URL: [Completion]]()

    init(networkService: NetworkService = URLSession(configuration: URLSessionConfiguration.default,
                                                     delegate: nil,
                                                     delegateQueue: OperationQueue.main)) {
        self.networkService = networkService
    }

    func fetchData(_ url: URL, _ completion: @escaping Completion) {
        let nsurl = url as NSURL

        /// Check for a cached image.
        if let object = cache.object(forKey: nsurl) {
            completion(object as Data)
            return
        }

        /// In case there are more than one requestor for the image, we append their completion block.
        loadingResponses[url, default: []].append(completion)

        /// If request is already running for same url, do not make another request
        if let req = runningRequests[url], req.isRunning {
            return
        }

        let task = networkService.fetch(url) { [weak self] result in
            guard let self = self else { return }

            defer {
                self.runningRequests[url] = nil
                self.loadingResponses[url] = nil
            }

            guard let data = try? result.get(),
                  let blocks = self.loadingResponses[url]
            else {
                completion(nil)
                return
            }
            /// Cache the data
            self.cache.setObject(data as NSData, forKey: nsurl)

            /// Iterate over each requestor for the data and pass it back.
            for block in blocks {
                block(data)
            }
        }

        runningRequests[url] = task
    }

    func cancel(url: URL) {
        runningRequests[url]?.cancel()
        runningRequests[url] = nil
        loadingResponses[url] = nil
    }
}

class Cell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var onReuse: (() -> ())?

    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse?()
        onReuse = nil
        cellImage.image = nil
        indicator.stopAnimating()
    }
}

class ImageLoaderVC: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    private lazy var loader = DataFetcher()

    private lazy var urls: [URL] = {
        var paths = [URL]()
        for i in 1...1000 {
            paths.append(URL(string: "https://picsum.photos/seed/\(i)/150")!)
        }
        return paths
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        urls.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
        cell.indicator.startAnimating()
        let url = urls[indexPath.row]
        cell.label.text = url.path
        loader.fetchData(url) { data in
            DispatchQueue.main.async {
                guard let data = data else { return }
                cell.cellImage.image = UIImage(data: data)
                cell.indicator.stopAnimating()
            }
        }
        cell.onReuse = { [weak self] in
            self?.loader.cancel(url: url)
        }
        return cell
    }
}
