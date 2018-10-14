
import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var localListas = [NSManagedObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    
    //UITableView----
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localListas.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath ) as! TableViewCell
        let lista = localListas[indexPath.row]
        cell.labelNombreLista.text = lista.valueForKey("nombre") as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showViewController2", sender: self)

    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "showViewController2"){
            let viewController2: ViewController2 = segue.destinationViewController as! ViewController2
            viewController2.nombreLista = (localListas[self.tableView.indexPathForSelectedRow!.row].valueForKey("nombre") as? String)!
        }
    }
    
    //Editar UITableView------
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            let nombre = self.localListas[indexPath.row].valueForKey("nombre") as? String
            
            print(indexPath.row)
            borrarListaV2(nombre!, indice: indexPath.row)
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if( editing ){
            self.tableView.setEditing(true, animated: true)
        }else{
            self.tableView.setEditing(false, animated: true)
        }
    
    }
    
    
    
    //Alert-----------
    @IBAction func newLista(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Nueva Lista", message: "", preferredStyle: .Alert)
        
        
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in }
        let cancelar = UIAlertAction(title: "Cancelar", style: .Default, handler: { (action:UIAlertAction) -> Void in })
        
        
        let guardar = UIAlertAction(title: "Guardar", style: .Default, handler: { (action: UIAlertAction) -> Void in
            
            let textField = alert.textFields!.first
            self.guardarLista( textField!.text! )
        })
        
        
        alert.addAction(cancelar)
        alert.addAction(guardar)
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func guardarLista( nombre: String ){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("Listas", inManagedObjectContext: context)
        let lista = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context)
        
        lista.setValue(nombre, forKey: "nombre")
        
        do{
            try context.save()
            self.localListas.append(lista)
            self.tableView.reloadData()
        }catch{
            print("Error al guardar")
        }
        
        
    }
    
    //Cargar Nombres de las listas--------
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Listas")

        do {
            
            let results = try context.executeFetchRequest(fetchRequest)
            self.localListas = results as! [NSManagedObject]
            self.tableView.reloadData()
        } catch {
            print("error al consultar")
        }
    }
    
    //Borrar Listas-----------
    func borrarLista( nombre: String, indice: Int ){
    
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest()
        
        let entityDescription = NSEntityDescription.entityForName("Listas", inManagedObjectContext: context)
        
        fetchRequest.entity = entityDescription
        
        do {
            let result = try context.executeFetchRequest(fetchRequest)
            
            
            if (result.count > 0) {
                
                var consult: Bool = false
                var i = 0
                var lista: NSManagedObject
                
                while( i < result.count && !consult){
                
                    lista = result[i] as! NSManagedObject
                    
                    if( (lista.valueForKey("nombre") as? String) == nombre){
                        consult = true
                    }
                    
                    if( consult ){
                        
                        context.deleteObject(lista)
                        
                        do{
                            try context.save()
                            self.localListas.removeAtIndex(indice)
                        }catch{
                            print("Error")
                        }
                    }
                    
                    i++
                }
                
            }
        } catch {
            print("Error al consultar borrar")
        }
        
        
        self.tableView.reloadData()

    }
    
    //Borar ListaV2------------------------------------------
    func borrarListaV2( nombre: String, indice: Int){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Listas", inManagedObjectContext: context)
        fetchRequest.entity = entityDescription
        
        do{
            let result = try context.executeFetchRequest(fetchRequest)
            if( result.count > 0){
                var consult: Bool = false
                var i = 0
                var lista: NSManagedObject
                while( i < result.count && !consult){
                    lista = result[i] as! NSManagedObject
                    
                    if( lista.valueForKey("nombre") as? String == nombre){
                        
                        do{
                            let appDelegate2 = UIApplication.sharedApplication().delegate as! AppDelegate
                            let context2 = appDelegate2.managedObjectContext
                            let entityAlumnos = NSEntityDescription.entityForName("Alumno", inManagedObjectContext: context2)
                            let requestAlumnos = NSFetchRequest()
                            requestAlumnos.entity = entityAlumnos
                            
                            let resultAlumnos = try context2.executeFetchRequest(requestAlumnos)
                            
                            if( resultAlumnos.count > 0){
                                var alumno: NSManagedObject
                                for(var k=0; k < resultAlumnos.count; k++){
                                    alumno = resultAlumnos[k] as! NSManagedObject
                                    if( alumno.valueForKey("lista") as? String == nombre){
                                        context2.deleteObject(alumno)
                                    }
                                }
                            }
                            
                        }catch{
                            print("Error borrar elementos de lista: \(nombre)")
                        }
                        
                        context.deleteObject(lista)
                        do{
                            try context.save()
                            self.localListas.removeAtIndex(indice)
                        }catch{
                            print("error al borrar lista")
                        }
                        consult = true
                    }
                    i++
                }
            }
            
        }catch{
            print("Error borrar v2")
        }
        self.tableView.reloadData()
    }
    
    //Consulta General -------------------------------------------
    
    @IBAction func consultaGeneral(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Alumno")
        
        do {
            
            let results = try context.executeFetchRequest(fetchRequest)
            
            print("-------------------------------")
            
            for(var i=0; i<results.count; i++){
                let alumno = results[i] as! NSManagedObject
                
                let nombre = alumno.valueForKey("nombre") as? String
                let matricula = alumno.valueForKey("matricula") as? String
                let lista = alumno.valueForKey("lista") as? String
                
                print(" \(nombre!) \(matricula!) \(lista!)")
                
            }
            
            
        } catch {
            print("error Consulta General")
        }
        
    }

}

