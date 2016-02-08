import UIKit
import GoogleMaps

class DetailViewController : UIViewController, UIScrollViewDelegate, GMSMapViewDelegate
{
    var woning : Woning?
    
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var navItem: UINavigationItem!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var mapView: UIView!
    
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var oppervlakteLabel: UILabel!
    @IBOutlet var roomLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    
    @IBOutlet var mainScroll: UIScrollView!
    
    var pageImages: [String] = []
    var pageViews: [UIImageView?] = []
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func callButtonPressed(sender: AnyObject) {
        if let tel = woning {
            let phone = "tel://" + tel.makelaarTelefoon
            let trimmedString = phone.stringByReplacingOccurrencesOfString(" ", withString: "")
            let url = NSURL(string:trimmedString)
            if let nsUrl = url {
                UIApplication.sharedApplication().openURL(nsUrl)
            }
        }
    }
    
    @IBAction func mailButtonPressed(sender: AnyObject) {
        if let mail = woning {
            let url = NSURL(string: "mailto:\(mail.makelaarEmail)")
            if let nsUrl = url {
                UIApplication.sharedApplication().openURL(nsUrl)
            }
        }
    }
    @IBOutlet var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainScroll.contentSize = mainView.frame.size
        navItem?.title = woning?.straatnaam
        self.priceLabel.text = "\(Int((woning?.prijs)!))"
        self.descLabel.text = "\(woning!.omschrijving)"
        self.oppervlakteLabel.text = "\(Int((woning?.prijs)!))"
        self.roomLabel.text = "\(Int((woning?.aantalKamers)!))"
        
        // 1
        for i in 0...woning!.afbeeldingen.count - 1
        {
            let imgString = woning!.afbeeldingen[i].string!
            pageImages.append(imgString)
        }
        
        let pageCount = pageImages.count
        
        // 2
        pageControl.currentPage = 0
        pageControl.numberOfPages = pageCount
        
        // 3
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        
        // 4
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(pageImages.count),
            height: pagesScrollViewSize.height)
        
        // 5
        loadVisiblePages()
        loadMap()
    }
    
    func loadMap() {
        let camera = GMSCameraPosition.cameraWithLatitude(woning!.coordLat,
            longitude: woning!.coordLong, zoom: 16)
        let frame = self.mapView.bounds
        
        let mapView = GMSMapView.mapWithFrame(frame, camera: camera)
        mapView.myLocationEnabled = true
        mapView.delegate = self
        mapView.settings.scrollGestures = false
        self.mapView.addSubview(mapView)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(woning!.coordLat, woning!.coordLong)
        marker.title = (woning?.straatnaam)! + " " + (woning?.huisnummer)!
        marker.map = mapView
        marker.icon = UIImage(named: "house")
    }
    
    //func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
    //
    //}
    
    func loadPage(page: Int) {
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // 1
        if let _ = pageViews[page] {
            // Do nothing. The view is already loaded.
        } else {
            // 2
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            // 3
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let img = self.getImage(self.pageImages[page])
                dispatch_async(dispatch_get_main_queue(), {
                    let newPageView = UIImageView(image: img)
                    newPageView.contentMode = .ScaleAspectFill
                    newPageView.frame = frame
                    self.scrollView.addSubview(newPageView)
                    // 4
                    self.pageViews[page] = newPageView
                });
            });
            
        }
    }
    
    func getImage(image: String) -> UIImage {
        if let dataURL = NSURL(string:image) {
            if let data = NSData(contentsOfURL: dataURL) {
                return UIImage(data: data)!
            }
        }
        return UIImage();
    }
    
    func purgePage(page: Int) {
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
    }
    
    func loadVisiblePages() {
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Update the page control
        pageControl.currentPage = page
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        // Purge anything before the first page
        for var index = 0; index < firstPage; ++index {
            purgePage(index)
        }
        
        // Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
        
        // Purge anything after the last page
        for var index = lastPage+1; index < pageImages.count; ++index {
            purgePage(index)
        }
    }

    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
    }
    
    
}
