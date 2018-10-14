

import UIKit
import CoreData

class ViewController2: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var nombreLista: String = ""
    
    var localAlumnos = [NSManagedObject]()

    @IBOutlet weak var tableView2: UITableView!
    @IBOutlet weak var labelNombreLista: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelNombreLista.text = nombreLista
        
    }
    
    
    //UITableView----------------------------
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localAlumnos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath ) as! TableViewCell2
        
        let alumno = localAlumnos[indexPath.row]
        
        cell.labelNombre.text = alumno.valueForKey("nombre") as? String
        cell.labelMatricula.text = alumno.valueForKey("matricula") as? String
        cell.labelAsistencias.text = alumno.valueForKey("asistencias") as? String
        
        return cell
        
    }
    
    //Editar UITableView------
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            let matricula = self.localAlumnos[indexPath.row].valueForKey("matricula") as? String
            borrarAlumno(matricula!, indice: indexPath.row)
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if( editing ){
            self.tableView2.setEditing(true, animated: true)
        }else{
            self.tableView2.setEditing(false, animated: true)
        }
        
    }
    
    
    
    //Nuevo Alumno -------------------------
    @IBAction func newAlumno(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Nuevo Alumno", message: "Datos", preferredStyle: .Alert)
        
        
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.placeholder = "ingresa nombre"
            let label:UILabel = UILabel(frame: CGRectMake(0, 0, 75, 30))
            label.text = "Nombre"
            textField.leftView = label
            textField.leftViewMode = UITextFieldViewMode.Always
        }
        
        alert.addTextFieldWithConfigurationHandler { (textField2: UITextField) -> Void in
            textField2.placeholder = "ingresa matricula"
            let label:UILabel = UILabel(frame: CGRectMake(0, 0, 75, 30))
            label.text = "Matricula"
            textField2.leftView = label
            textField2.leftViewMode = UITextFieldViewMode.Always
        }
        
        
        let cancelar = UIAlertAction(title: "Cancelar", style: .Default, handler: { (action:UIAlertAction) -> Void in })
        
        
        let guardar = UIAlertAction(title: "Guardar", style: .Default, handler: { (action: UIAlertAction) -> Void in
        
            let nombre = alert.textFields!.first
            let matricula = alert.textFields!.last
            
            self.guardarAlumno( nombre!.text!, matricula: matricula!.text! )
        })
        
        
        alert.addAction(cancelar)
        alert.addAction(guardar)
        
        presentViewController(alert, animated: true, completion: nil)

        
    }
    
    func guardarAlumno( nombre: String, matricula: String ){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("Alumno", inManagedObjectContext: context)
        let alumno = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context)
        
        alumno.setValue(nombre, forKey: "nombre")
        alumno.setValue(matricula, forKey: "matricula")
        alumno.setValue("0", forKey: "asistencias")
        alumno.setValue(self.nombreLista, forKey: "lista")
        
        do{
            try context.save()
            self.localAlumnos.append(alumno)
            self.tableView2.reloadData()
        }catch{
            print("Error al guardar")
        }
        
        
    }
    
    //Cargar Valores-------------//Cargar Nombres de Alumnos--------
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var listAlumnos = [NSManagedObject]()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Alumno")
        
        do {
            
            let results = try context.executeFetchRequest(fetchRequest)
            
            for( var i = 0; i < results.count; i++ ){
                
                let lista = results[i].valueForKey("lista") as? String
                
                if( lista == nombreLista ){
                    listAlumnos.append(results[i] as! NSManagedObject)
                }
            }
            self.localAlumnos = listAlumnos
            
            
        } catch {
            print("error al consultar")
        }
        
        self.tableView2.reloadData()
    }

    @IBOutlet weak var editButtonVar: UIBarButtonItem!
    @IBAction func editButton(sender: AnyObject) {
        
        if( tableView2.editing ){
            tableView2.setEditing(false, animated: true)
            editButtonVar.title = "Done"
        }else{
            editButtonVar.title = "Done"
            tableView2.setEditing(true, animated: true)
        }
    }
    
    //Borrar Alumno-----------
    func borrarAlumno( matricula: String, indice: Int ){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest()
        
        let entityDescription = NSEntityDescription.entityForName("Alumno", inManagedObjectContext: context)
        
        fetchRequest.entity = entityDescription
        
        do {
            let result = try context.executeFetchRequest(fetchRequest)
            
            
            if (result.count > 0) {
                
                var consult: Bool = false
                var i = 0
                var alumno: NSManagedObject
                
                while( i < result.count && !consult){
                    
                    alumno = result[i] as! NSManagedObject
                    
                    if( (alumno.valueForKey("matricula") as? String) == matricula){
                        consult = true
                    }
                    
                    if( consult ){
                        
                        context.deleteObject(alumno)
                        
                        do{
                            try context.save()
                            self.localAlumnos.removeAtIndex(indice)
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
        
        
        self.tableView2.reloadData()
        
    }

    

}
