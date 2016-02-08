import UIKit;

class TableToDetailSeque: UIStoryboardSegue {
    
    override func perform() {
        let sourceVC = self.sourceViewController
        let destVC = self.destinationViewController
        
        sourceVC.view.addSubview(destVC.view)
        destVC.view.transform = CGAffineTransformMakeScale(0.05, 0.05)
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
            
            destVC.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
            
            }) { (finished) -> Void in
                
                dispatch_async(dispatch_get_main_queue()){
                    sourceVC.presentViewController(destVC, animated: false, completion:nil)
                }
                
                destVC.removeFromParentViewController()
        }
        
    }
    
}
