# gmlObject.tcl --
#
#   Implements an object mechanism in Tcl.
#
#   Copyright (c) 2001-2005 LIG/IIHM
#
#   See the file "gml_LicenseTerms.txt" for information on usage and redistribution
#   of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
#   Version 1.072, Oct. 2, 2007: FB
#     Added method "setAttribute" to gmlObjRootClass.
#
#   Version 1.071, Aug. 29, 2005: FB
#     "gmlObject info methods" now prefixes inherited method by the <name of the supperclass>::
#
#   Version 1.07, Sept. 4, 2004: FB
#     Call to the constructor is no more protected in a catch: errors are reported immediately
#       without trying to cleanup the partially constructed object.
#
#   Version 1.06, July 30, 2004: FB
#     WARNING! Icompatibility: the destructor is now called even if the call to the
#       constructor failed.
#
#   Version 1.05, July 27, 2004: FB
#     Added "newName" method to gmlObjRootClass.
#
#   Version 1.04, June 23, 2004: FB
#     Added "attribute" method to gmlObjRootClass.
#     Now correctly handles strange object name such as containing spaces.
#
#   Version 1.033, March 1, 2004: FB
#     Classes and objects can now be renamed with the "rename" tcl command.
#
#   Version 1.032, December 1, 2003: FB
#     Added "gmlObject info objects all"
#
#   Version 1.031, October 1, 2003: FB
#     Corrected a bug that prevented "gmlObject info class" and "gmlObject info interface"
#       to work.
#
#   Version 1.03, September 22, 2003: FB
#     Corrected a bug in "gmlObject info classes <className>" that would provoque an error.
#     Completed "gmlObject info class <className>" to include inherit commands.
#     Completed "gmlObject info methods (<className> | <objName)" to accept objects (used to
#       accept only classes.
#     "gmlObject info methods ..." now returns a list containing inherited methods (used to return
#       only the class methods). The same list is included in the error message when calling a
#       non-existant method on an object.
#
#   Version 1.02, April 13, 2003: FB
#     Better "errorInfo" handling:
#       When a constructor or a destructor generates an error, the call stack
#       is correctly stored in the global variable errorInfo.
#
#     "inherit" inserts superclasses in the head of the list so
#       that the last inherited class are searched first for
#       inherited methods.
#
#     "inherit" silently returns when inheriting from a class that
#       is already an ancestor (it used to report an error in this case).
#
#     Fixed and changed the "inherited" method mechanism:
#       The "inherited" method can only be called in the context of a
#       specialized method and on the object "this". Thus it is no longer necessary
#       to specify the name of the inherited method because it is the name of
#       the calling method. Example of a call: "this inherited x y z".
#
#     Added the "unknown" method mechanism:
#       when an unknown method is called on an object, it is replaced by a call to
#       the "unknown" method. The name of the unknown method is placed at the head
#       of the arguments.
#       For example: object "O" has no method "m". The call "O m x y z" is
#       replaced by the call "O unknown m x y z".
#       By default, every object inherits from "gmlObjRootClass" "unknown" method
#       that simply reports an error.
#
#   Version 1.01, Januray 25, 2003: FB
#     added the possibility to specify a base class on method calls:
#       "objName aBaseClass::methodName ..."
#     "inherit" now auto-loads the definition file of the superclass
#       if it is not yet defined when "inherit" is called.
#
#   Version 1.0, March 14, 2002: FB
#
#   Created on December 28, 2001 (FB).

# Side effects:
#
#   Function (re)definitions:
#     method
#     inherit
#     this
#     gmlObjInit
#     gmlObjDestroy
#     gmlObjClassExists
#     gmlObjObjectExists
#     gmlObjMethodExists
#     gmlObjNewClass
#     gmlObjDeleteClass
#     gmlObjNewObject
#     gmlObjDeleteObject
#     gmlObjDeleteMethod
#     gmlObjRenameEntity
#     gmlObject
#     gmlObject_delete
#     gmlObject_info
#     gmlObjObjectDispatch
#     gmlObjFindMethod
#     gmlObjIsAncestor
#     gmlObjBuildClassList
#     gmlObjBuildMethodList
#     one function for every method, the name of the function is
#       "gmlObj_" followed by the class name (class methods) or the object name (object methods),
#       followed by underscore ("_"), followed by the method name.
#       For example for the method named "method" of the class named "class":
#       "gmlObj_class_method"
#
#   Global variable definitions:
#     gmlObject
#     one variable for every object, the name of the variable is the name of the object.
#     one variable for every class, the name of the variable is the name of the class.


proc gmlObjInit {} {
global gmlObject

  if { ![info exists gmlObject] } {
    set gmlObject(classes)    [list]

    # gmlObjRootClass::dispose --
    #
    #   Destroy the object.

    method gmlObjRootClass dispose {} {
      gmlObject delete object $objName
    }

    # gmlObjRootClass::attribute --
    #
    #   Returns the value of the object attribute named <name>.

    method gmlObjRootClass attribute { name } {
      return $this($name)
    }

    # gmlObjRootClass::setAttribute --
    #
    #   Set the value of object's attribute <name> to <value>.

    method gmlObjRootClass setAttribute { name value } {
      return [set this($name) $value]
    }

    # gmlObjRootClass::attributes --
    #
    #   Returns the value of the object attributes which names are
    #    in the list <args>.

    method gmlObjRootClass attributes { args } {
      set res [list]
      foreach attribute $args {
        lappend res $this($attribute)
      }
      return $res
    }

    # gmlObjRootClass::newName --
    #
    #   Creates a new object that is a new name for this object (the base object) and name it <name>.
    #   A new name object shares its state with the base object. The only difference
    #     between the base object and the new name object is when disposing:
    #     disposing the new name object does not affect the base object.
    #     disposing the base object disposes all its new name objects.
    #   A new name object can act as a base objects to its own new names.

    method gmlObjRootClass newName { name } {
      gmlObjNewObject $objName [gmlObject info classofobject $objName] $name
    }

    # gmlObjRootClass::unknown --
    #
    #   The "unknown" method is called when an undefined method is called on this object.
    #   The name of the undefined method is passed in the <method> argument, and the
    #     call arguments are concatened in the <args> argument.

    method gmlObjRootClass unknown { method args } {
    global gmlObject

      error "invalid method name \"$method\": should be one of \"[gmlObjBuildMethodList [gmlObject info classofobject $objName]]\""
    }
  }
}



proc gmlObjDestroy {} {
global gmlObject

  if { [info exists gmlObject] } {
    if { [info exists gmlObject(classes)] } {
      foreach tmpClass $gmlObject(classes) {
        if { [catch { gmlObjDeleteClass $tmpClass } tmpRes] } {
          puts stderr "gmlObjDestroy: WARNING, could not delete class \"$tmpClass\": $tmpRes"
        }
      }
    }

    unset gmlObject
  }

  foreach tmpFunction [list \
    method \
    inherit \
    this \
    gmlObjInit \
    gmlObjDestroy \
    gmlObjClassExists \
    gmlObjObjectExists \
    gmlObjMethodExists \
    gmlObjNewClass \
    gmlObjDeleteClass \
    gmlObjNewObject \
    gmlObjDeleteObject \
    gmlObjDeleteMethod \
    gmlObjRenameEntity \
    gmlObject \
    gmlObject_delete \
    gmlObject_info \
    gmlObjObjectDispatch \
    gmlObjFindMethod \
    gmlObjIsAncestor \
    gmlObjBuildClassList \
    gmlObjBuildMethodList \
                      ] {
    if { [catch { rename $tmpFunction {} } tmpRes] } {
      puts stderr "gmlObjDestroy: WARNING, could not delete function \"$tmpFunction\": $tmpRes"
    }
  }
  return
}



proc gmlObjClassExists { className } {
global gmlObject

  return [info exists gmlObject(class,$className,classes)]
}

proc gmlObjObjectExists { objName } {
global gmlObject

  return [info exists gmlObject(object,$objName,class)]
}

proc gmlObjMethodExists { className methodName } {
global gmlObject

  return [info exists gmlObject(class,$className,method,$methodName)]
}



proc gmlObjNewClass { className } {
global gmlObject
upvar #0 $className class

  if { [info exists class] } {
    error "could not create class \"$className\": a global variable with that name already exists"
  }
  if { [llength [info command $className]] } {
    error "could not create class \"$className\": a command with that name already exists"
  }
  set gmlObject(class,$className,objects)         [list]
  set gmlObject(class,$className,methods)         [list]
  set gmlObject(class,$className,classes)         [list]
  set gmlObject(class,$className,specializations) [list]

  proc $className { args } "return \[uplevel gmlObjNewObject [list [list {}]] $className \$args\]"

  lappend gmlObject(classes) $className

  if { ![string equal $className gmlObjRootClass] } {
    inherit $className gmlObjRootClass
  }

  trace add command $className rename "gmlObjRenameEntity class"

  return
}



proc gmlObjDeleteClass { className } {
global gmlObject
upvar #0 $className class

  trace remove command $className rename "gmlObjRenameEntity class"

  set tmpIdx    [lsearch -exact $gmlObject(classes) $className]
  if { $tmpIdx != -1 } {
    # remove this class as a specialization of its parent classes
    foreach tmpSuperName $gmlObject(class,$className,classes) {
      set tmpIdx2   [lsearch -exact $gmlObject(class,$tmpSuperName,specializations) $className]
      if { $tmpIdx2 != -1 } {
        set gmlObject(class,$tmpSuperName,specializations) \
              [lreplace $gmlObject(class,$tmpSuperName,specializations) $tmpIdx2 $tmpIdx2]
      }
    }

    # delete all objects of this class
    foreach tmpObjName $gmlObject(class,$className,objects) {
      if { [catch { gmlObjDeleteObject $tmpObjName } tmpRes] } {
        puts stderr "gmlObjDeleteClass WARNING, while deleting object \"$tmpObjName\": $tmpRes"
      }
    }
    unset gmlObject(class,$className,objects)

    # delete all methods of this class
    foreach tmpMethodName $gmlObject(class,$className,methods) {
      if { [catch { gmlObjDeleteMethod $className $tmpMethodName } tmpRes] } {
        puts stderr "gmlObjDeleteClass WARNING, could not delete method \"$tmpMethodName\": $tmpRes"
      }
    }
    unset gmlObject(class,$className,methods)

    # delete class from gmlObject, delete class procedure and global variable
    unset gmlObject(class,$className,classes)
    rename $className {}
    if { [info exists class] } {
      unset class
    }

    set gmlObject(classes) [lreplace $gmlObject(classes) $tmpIdx $tmpIdx]
  }

  return
}



proc gmlObjNewObject { baseObj className objName args } {
global gmlObject errorInfo
upvar #0 $objName this

  set tmpClone                                    [expr [string length $baseObj] != 0]

  set tmpConstructor                              [gmlObjMethodExists $className constructor]
  if { !$tmpConstructor && ([llength $args] != 0) } {
    error "too many args: there is no constructor"
  }
  if { [info exists this] } {
    error "could not create object \"$objName\": a global variable with that name already exists"
  }
  if { [llength [info procs $objName]] } {
    error "could not create object \"$objName\": a procedure with that name already exists"
  }
  set gmlObject(object,$objName,class)            $className
  set gmlObject(object,$objName,newNames)         [list]

  lappend gmlObject(class,$className,objects)     $objName

  proc $objName { args } "return \[uplevel gmlObjObjectDispatch [list [list $objName]] \$args\]"

  if { $tmpClone } {

    set gmlObject(object,$objName,baseObj)        $baseObj
    lappend gmlObject(object,$baseObj,newNames)   $objName

    uplevel #0 upvar #0 [list $baseObj] [list $objName]

  } else {

    set gmlObject(object,$objName,baseObj)        {}
    trace add command                             $objName rename "gmlObjRenameEntity object"

    # Call the constructor if it exists.

    if { $tmpConstructor } {
      if { [catch { uplevel gmlObjObjectDispatch [list $objName] constructor $args } tmpRes] } {
        set tmpSavedInfo $errorInfo
        gmlObjDeleteObject $objName 0
        error $tmpRes $tmpSavedInfo
      }
    }
  }

  return $objName
}



proc gmlObjDeleteObject { objName { reportDestructorError 1 } } {
global gmlObject errorInfo
upvar #0 $objName this

  set tmpClass            $gmlObject(object,$objName,class)
  set tmpCloneof          $gmlObject(object,$objName,baseObj)
  set tmpClone            [expr [string length $tmpCloneof] != 0]

  trace remove command    $objName rename "gmlObjRenameEntity object"

  # Delete all of this object new names.

  foreach tmpCloneName $gmlObject(object,$objName,newNames) {
    gmlObjDeleteObject $tmpCloneName
  }

  set tmpDestructError 0
  if { $tmpClone } {

    # remove this object from its base object new name list.

    set tmpIdx [lsearch -exact $gmlObject(object,$tmpCloneof,newNames) $objName]
    if { $tmpIdx == -1 } {
      error "gmlObjDeleteObject ${objName}: object not found in the list of newNames of its base object"
    }
    set gmlObject(object,$tmpCloneof,newNames) \
             [lreplace $gmlObject(object,$tmpCloneof,newNames) $tmpIdx $tmpIdx]

    # remove this object name reference to base object global variable.

    uplevel #0 upvar #0 [list {}] [list $objName]

  } else {

    # Call destructor if it exists.

    if { [gmlObjMethodExists $tmpClass destructor] } {
      set tmpDestructError [catch {
        uplevel gmlObjObjectDispatch [list $objName] destructor
      } tmpDestructRes]
      set tmpSavedErrorInfo $errorInfo
    }

    # unset the global variable that stored the object attributes

    if { [info exists this] } {
      unset this
    }
  }

  # cleanup this object data in the global gmlObject array

  unset gmlObject(object,$objName,class)
  unset gmlObject(object,$objName,baseObj)
  unset gmlObject(object,$objName,newNames)

  # delete this object references from its class

  set tmpIdx [lsearch -exact $gmlObject(class,$tmpClass,objects) $objName]
  if { $tmpIdx == -1 } {
    error "gmlObjDeleteObject ${objName}: object not found in the list of objects of its class"
  }
  set gmlObject(class,$tmpClass,objects) \
           [lreplace $gmlObject(class,$tmpClass,objects) $tmpIdx $tmpIdx]

  rename $objName {}

  if { $tmpDestructError && $reportDestructorError } {
    error $tmpDestructRes $tmpSavedErrorInfo
  }
  return
}



# this --
#
#   Execute another method of the calling object.
#
#   Only valid inside a method.

proc this { args } {
upvar objName this

  return [uplevel gmlObjObjectDispatch [list $this] $args]
}


# method --
#
#   Create or modify a method named <methodName> in class <className>.
#   The method will accept arguments in <paramList> (formatted like the
#   second parameter of Tcl's <proc> command), and will execute <body>
#   when called.
#
#   Class <className> will be created if it didn't exist prior to the call.

proc method { args } {
global gmlObject

  gmlObjInit

  if { [llength $args] != 4 } {
    error "wrong # args: should be \"method className methodName args body\""
  }

  foreach { className methodName paramList body } $args {

    # If the class doesn't exist yet, create it.

    if { ![gmlObjClassExists $className] } {
      gmlObjNewClass $className
    }

    set tmpBodyHeader "upvar #0 \$className class \$objName this\n"

    proc gmlObj_${className}_$methodName \
           [linsert $paramList 0 objName className methodName] \
           $tmpBodyHeader$body

    if { ![gmlObjMethodExists $className $methodName] } {
      lappend gmlObject(class,$className,methods)        $methodName
      set gmlObject(class,$className,method,$methodName) {}
    }
  }
  return
}



proc gmlObjDeleteMethod { className methodName } {
global gmlObject

  set tmpListIndex class,$className,methods
  set tmpIdx [lsearch -exact $gmlObject($tmpListIndex) $methodName]
  if { $tmpIdx == -1 } {
    error "gmlObjDeleteMethod ${className}::${methodName}: method not found in the list of methods"
  }
  set gmlObject($tmpListIndex) \
         [lreplace $gmlObject($tmpListIndex) $tmpIdx $tmpIdx]

  if { ![string length $gmlObject(class,$className,method,$methodName)] } {
    rename gmlObj_${className}_$methodName {}
  }
  unset gmlObject(class,$className,method,$methodName)

  return
}



proc gmlObjRenameEntity { classOrObj oldName newName op } {
  regexp {(::|)(.+)$} $oldName dum dum oldName
  regexp {(::|)(.+)$} $newName dum dum newName

global gmlObject
upvar #0 $oldName old $newName new

  if { [info exists new] } {
    unset new
  }

  set oldPrefix     ${classOrObj},${oldName},
  set oldPrefixLen  [string length $oldPrefix]
  set newPrefix     ${classOrObj},${newName},
  set newList       [list]
  foreach { idx val } [array get gmlObject ${oldPrefix}*] {
    lappend newList ${newPrefix}[string range $idx $oldPrefixLen end] $val
  }
  array unset gmlObject ${oldPrefix}*
  array set   gmlObject $newList

  if { [info exists old] } {
    foreach idx [array names old] {
      set new($idx)   $old($idx)
    }
    unset old
  }

  switch -exact $classOrObj \
    class {

      # rename in gmlObject list of all classes
      set idx                   [lsearch -exact $gmlObject(classes) $oldName]
      set gmlObject(classes)    [lreplace $gmlObject(classes) $idx $idx $newName]

      # rename in this class superclasses's specializations
      foreach tmpSuper $gmlObject(class,$newName,classes) {
        set idx   [lsearch -exact $gmlObject(class,$tmpSuper,specializations) $oldName]
        set gmlObject(class,$tmpSuper,specializations) \
                  [lreplace $gmlObject(class,$tmpSuper,specializations) $idx $idx $newName]
      }

      # rename in this class specializations' superclasses
      foreach tmpSpec $gmlObject(class,$newName,specializations) {
        set idx   [lsearch -exact $gmlObject(class,$tmpSpec,classes) $oldName]
        set gmlObject(class,$tmpSpec,classes) \
                  [lreplace $gmlObject(class,$tmpSpec,classes) $idx $idx $newName]
      }

      # rename this class objects' class
      foreach tmpObj $gmlObject(class,$newName,objects) {
        set gmlObject(object,$tmpObj,class) $newName
      }

      # rename all methods' procs
      foreach tmpMethod $gmlObject(class,$newName,methods) {
        rename gmlObj_${oldName}_$tmpMethod gmlObj_${newName}_$tmpMethod
      }

      # redefine this class proc, re-register rename handler
      proc $newName { args } "return \[uplevel gmlObjNewObject [list [list {}]] $newName \$args\]"

      trace add command $newName rename "gmlObjRenameEntity class"
    } \
    object {
      # rename in this object's class object list
      set tmpClass  $gmlObject(object,$newName,class)
      set idx       [lsearch -exact $gmlObject(class,$tmpClass,objects) $oldName]
      set gmlObject(class,$tmpClass,objects) \
                    [lreplace $gmlObject(class,$tmpClass,objects) $idx $idx $newName]

      # redefine this object proc, re-register rename handler
      proc $newName { args } "return \[uplevel gmlObjObjectDispatch [list [list $newName]] \$args\]"

      trace add command $newName rename "gmlObjRenameEntity object"
    }
}


proc gmlObjObjectDispatch { objName methodName args } {
global gmlObject

  set tmpObjClass       $gmlObject(object,$objName,class)

  if { [regexp {^(.+)::([^:]+)$} $methodName tmpMatch tmpSuperClass methodName] } {
    if { ![gmlObjIsAncestor $tmpObjClass $tmpSuperClass] } {
      error "\"$tmpSuperClass\" is not an ancestor of \"$tmpObjClass\""
    }
    set tmpFound [gmlObjFindMethod $tmpSuperClass $methodName 1 tmpFoundClass]

  } else {
    if { [string equal $methodName "inherited"] } {
      upvar className tmpCallClassName objName tmpCallObjName methodName tmpCallMethodName

      if {  (![info exists tmpCallClassName])            ||
            (![info exists tmpCallObjName])              ||
            (![info exists tmpCallMethodName])           ||
            (![string equal $objName $tmpCallObjName])       } {
        error "\"inherited\" can only be invoked on \"this\" in the context of a method"
      }
      set methodName $tmpCallMethodName
      set tmpFound [gmlObjFindMethod $tmpCallClassName $methodName 0 tmpFoundClass]

    } else {
      set tmpFound [gmlObjFindMethod $tmpObjClass $methodName 1 tmpFoundClass]
    }
  }

  if { ! $tmpFound } {
    return [uplevel [list $objName] unknown $methodName $args]
  }

  return [uplevel gmlObj_${tmpFoundClass}_$methodName [list $objName] $tmpFoundClass $methodName $args]
}



proc gmlObjFindMethod { className methodName searchInBase resVarName } {
global gmlObject
upvar $resVarName res

  if { $searchInBase } {
    if { [gmlObjMethodExists $className $methodName] } {
      set res $className
      return 1
    }
  }
  foreach tmpClassName $gmlObject(class,$className,classes) {
    if { [gmlObjFindMethod $tmpClassName $methodName 1 res] } {
      return 1
    }
  }
  return 0
}



proc gmlObjIsAncestor { className ancestorName } {
global gmlObject

  set tmpAncestors    $gmlObject(class,$className,classes)

  if { [lsearch -exact $tmpAncestors $ancestorName] != -1 } {
    return 1
  }
  foreach tmpClassName $tmpAncestors {
    if { [gmlObjIsAncestor $tmpClassName $ancestorName] } {
      return 1
    }
  }
  return 0
}



# inherit --
#
#   Make <className> inherit all the methods from <superClassName>.
#   The class named <superClassName> must exist before the call, or must be prensent
#   in the auto_array index.
#   The class named <className> is created if it doesn't exist before the call.
#
#   If <superClassName> is already an ancestor of <className>, simply returns without
#   complaining.

proc inherit { className superClassName } {
global gmlObject auto_index

  gmlObjInit

  if { ![gmlObjClassExists $className] } {
    gmlObjNewClass $className
  }
  if { ![gmlObjClassExists $superClassName] } {
    if { ![auto_load $superClassName] } {
      error "class \"$superClassName\" does not exist"
    }
  }
  if { [gmlObjIsAncestor $superClassName $className] } {
    error "class \"$className\" is an ancestor of class \"$superClassName\""
  }
  if { [gmlObjIsAncestor $className $superClassName] } {
    return
  }
  set gmlObject(class,$className,classes) \
        [linsert $gmlObject(class,$className,classes) 0 $superClassName]
  lappend gmlObject(class,$superClassName,specializations) $className

  return
}


# gmlObject --
#
#   Inspect and modify defined objects and classes.
#
#
#   Usage:
#
#     gmlObject delete class  <className>
#     gmlObject delete method <className> <methodName>
#     gmlObject delete object <objectName>
#
#     gmlObject info args             <className> <methodName>
#     gmlObject info arglist          <className> <methodName>
#     gmlObject info body             <className> <methodName>
#     gmlObject info class            <className>
#     gmlObject info classes          ?(<objectName>|<className>)?
#     gmlObject info classofobject    <objName>
#     gmlObject info exists           (class|object) <name>
#     gmlObject info interface        ?(<objectName>|<className>)?
#     gmlObject info methods          (<objectName>|<className>)
#     gmlObject info objects          ?<className>?
#     gmlObject info specializations  <className>


proc gmlObject { args } {

  if { [llength $args] < 1 } {
    error "wrong # args: should be \"gmlObject <command> ?option? ...\""
  }

  set tmpCommandList  [list "delete" "info"]
  set tmpCommand      [lindex $args 0]
  if { [lsearch -exact $tmpCommandList $tmpCommand] == -1 } {
    error "wrong command \"$tmpCommand\": should be delete, or info"
  }

  return [uplevel gmlObject_$tmpCommand [lrange $args 1 end]]
}



proc gmlObject_delete { args } {
global gmlObject

  if { ([llength $args] < 2) } {
    error "wrong # args: should be \"gmlObject delete (class <name> | method <className> <methodName> | object <name>)\""
  }
  set tmpType     [lindex $args 0]
  set tmpName     [lindex $args 1]
  switch $tmpType \
    "class" {
      if { ([llength $args] != 2) } {
        error "wrong # args: should be \"gmlObject delete class <name>\""
      }
      if { ![gmlObjClassExists $tmpName] } {
        error "there is no class named \"$tmpName\""
      }
      uplevel gmlObjDeleteClass $tmpName
    } \
    "object" {
      if { ([llength $args] != 2) } {
        error "wrong # args: should be \"gmlObject delete object <name>\""
      }
      if { ![gmlObjObjectExists $tmpName] } {
        error "there is no object named \"$tmpName\""
      }
      uplevel gmlObjDeleteObject [list $tmpName]
    } \
    "method" {
      if { ([llength $args] != 3) } {
        error "wrong # args: should be \"gmlObject delete method <className> <methodName>\""
      }
      set tmpClassName   [lindex $args 1]
      set tmpMethodName  [lindex $args 2]
      if { ![gmlObjClassExists $tmpClassName] } {
        error "there is no class named \"$tmpClassName\""
      }
      uplevel gmlObjDeleteMethod $tmpClassName $tmpMethodName
    } \
    default {
      error "wrong entity \"$tmpType\": should be class, method or object"
    }

  return
}



proc gmlObjBuildClassList { type entityName } {
global gmlObject

  switch $type \
    object {
      if { ![gmlObjObjectExists $entityName] } {
        error "there is no object named \"$entityName\""
      }
      set tmpClassName $gmlObject(object,$entityName,class)
      return [concat $tmpClassName [gmlObjBuildClassList class $tmpClassName]]

    } \
    class {
      if { ![gmlObjClassExists $entityName] } {
        error "there is no class named \"$entityName\""
      }
      set tmpSupers   $gmlObject(class,$entityName,classes)
      set tmpRes      $tmpSupers

      foreach tmpSuper $tmpSupers {
        set tmpInherited [gmlObjBuildClassList class $tmpSuper]
        foreach tmpClass $tmpInherited {
          if { [lsearch -exact $tmpRes $tmpClass] == -1 } {
            lappend tmpRes $tmpClass
          }
        }
      }
    }

  return $tmpRes
}



proc gmlObjBuildMethodList { className { withSuperPrefix 0 } } {
global gmlObject

  if { ![gmlObjClassExists $className] } {
    error "there is no class named \"$className\""
  }
  set tmpRes        $gmlObject(class,$className,methods)

  foreach tmpSuper $gmlObject(class,$className,classes) {
    set tmpInherited [gmlObjBuildMethodList $tmpSuper $withSuperPrefix]
    foreach tmpMethod $tmpInherited {
      if { [lsearch -exact $tmpRes $tmpMethod] == -1 } {
        if { $withSuperPrefix &&
            (![regexp {^(.+)::([^:]+)$} $tmpMethod]) } {
          set tmpMethod ${tmpSuper}::$tmpMethod
        }
        lappend tmpRes $tmpMethod
      }
    }
  }

  return [lsort -dictionary $tmpRes]
}



proc gmlObject_info { args } {
global gmlObject

  set tmpArgLen   [llength $args]
  if { $tmpArgLen == 0 } {
    error "wrong #args: should be \"gmlObject info <option> ...\""
  }

  set tmpOption   [lindex $args 0]
  switch $tmpOption \
    "arglist" {
      if { $tmpArgLen != 3 } {
        error "wrong #args: should be \"gmlObject info arglist <className> <methodName>\""
      }
      foreach { tmpClassName tmpMethodName } [lrange $args 1 2] {
        if { ![gmlObjMethodExists $tmpClassName $tmpMethodName] } {
          error "there is no class/method named \"${tmpClassName}::$tmpMethodName\""
        }
        set tmpProcName gmlObj_${tmpClassName}_${tmpMethodName}
        set tmpList [list]
        foreach tmpArg \
          [lrange [info args $tmpProcName] 3 end] {
          if { [info default $tmpProcName $tmpArg tmpDefault] } {
            lappend tmpList [list $tmpArg $tmpDefault]
          } else {
            lappend tmpList $tmpArg
          }
        }
        return $tmpList
      }
    } \
    "args" {
      if { $tmpArgLen != 3 } {
        error "wrong #args: should be \"gmlObject info args <className> <methodName>\""
      }
      foreach { tmpClassName tmpMethodName } [lrange $args 1 2] {
        if { ![gmlObjMethodExists $tmpClassName $tmpMethodName] } {
          error "there is no class/method named \"${tmpClassName}::$tmpMethodName\""
        }
        return [lrange [info args gmlObj_${tmpClassName}_${tmpMethodName}] 3 end]
      }
    } \
    "body" {
      if { $tmpArgLen != 3 } {
        error "wrong #args: should be \"gmlObject info body <className> <methodName>\""
      }
      foreach { tmpClassName tmpMethodName } [lrange $args 1 2] {
        if { ![gmlObjMethodExists $tmpClassName $tmpMethodName] } {
          error "there is no class/method named \"${tmpClassName}::$tmpMethodName\""
        }
        regexp {(^upvar \#0 \$className class \$objName this\n)(.*)} \
         [info body gmlObj_${tmpClassName}_${tmpMethodName}] tmpDum tmpHead tmpTail
        return $tmpTail
      }
    } \
    "class" {
      if { $tmpArgLen != 2 } {
        error "wrong #args: should be \"gmlObject info class <className>\""
      }
      set tmpClassName [lindex $args 1]
      if { ![gmlObjClassExists $tmpClassName] } {
        error "there is no class named \"$tmpClassName\""
      }
      set tmpCode {}
      foreach tmpMethodName $gmlObject(class,$tmpClassName,methods) {
        set tmpCode "${tmpCode}method $tmpClassName $tmpMethodName { "
        set tmpCode "${tmpCode}[gmlObject info arglist $tmpClassName $tmpMethodName]"
        set tmpCode "${tmpCode} } {[gmlObject info body $tmpClassName $tmpMethodName]}\n"
      }
      set tmpInheritance {}
      foreach tmpSuperName [gmlObject info classes $tmpClassName] {
        if { ![string equal $tmpSuperName gmlObjRootClass] } {
          set tmpInheritance "inherit $tmpClassName $tmpSuperName\n$tmpInheritance"
        }
      }
      if { [string length $tmpInheritance] } {
        set tmpCode $tmpCode\n$tmpInheritance
      }
      return $tmpCode
    } \
    "classes" {
      if { $tmpArgLen == 1 } {
        return $gmlObject(classes)
      }
      if { $tmpArgLen > 2 } {
        error "wrong #args: should be \"gmlObject info classes ?(<objectName>|<className>)?\""
      }
      set tmpEntityName [lindex $args 1]
      if { [gmlObjObjectExists $tmpEntityName] } {
        return [gmlObjBuildClassList object $tmpEntityName]
      } else {
        return [gmlObjBuildClassList class  $tmpEntityName]
      }
    } \
    "classofobject" {
      if { $tmpArgLen != 2 } {
        error "wrong #args: should be \"gmlObject info classofobject <objName>\""
      }
      set tmpObjName [lindex $args 1]
      if { ![gmlObjObjectExists $tmpObjName] } {
        error "there is no object named \"$tmpObjName\""
      }
      return [lindex $gmlObject(object,$tmpObjName,class) 0]
    } \
    "exists" {
      if { $tmpArgLen != 3 } {
        error "wrong #args: should be \"gmlObject info exists (class|object) <name>\""
      }
      set tmpClassOrObject      [lindex $args 1]
      if { [string equal $tmpClassOrObject "object"] } {
        return [gmlObjObjectExists [lindex $args 2]]
      } elseif { [string equal $tmpClassOrObject "class"] } {
        return [gmlObjClassExists [lindex $args 2]]
      } else {
        error "wrong option \"$tmpClassOrObject\": should be class or object"
      }
    } \
    "interface" {
      if { $tmpArgLen != 2 } {
        error "wrong #args: should be \"gmlObject info interface ?(<objectName>|<className>)?\""
      }
      set tmpEntityName [lindex $args 1]
      if { [gmlObjObjectExists $tmpEntityName] } {
        set tmpClassName $gmlObject(object,$tmpEntityName,class)
      } else {
        set tmpClassName $tmpEntityName
      }
      if { ![gmlObjClassExists $tmpClassName] } {
        error "there is no class named \"$tmpClassName\""
      }
      set tmpCode {}
      foreach tmpMethodName $gmlObject(class,$tmpClassName,methods) {
        set tmpCode "${tmpCode}method $tmpClassName $tmpMethodName { "
        set tmpCode "${tmpCode}[gmlObject info arglist $tmpClassName $tmpMethodName]"
        set tmpCode "${tmpCode} }\n"
      }
      return $tmpCode
    } \
    "methods" {
      if { $tmpArgLen != 2 } {
        error "wrong #args: should be \"gmlObject info methods (<objectName> | <className>)\""
      }
      set tmpEntityName [lindex $args 1]
      if { [gmlObjObjectExists $tmpEntityName] } {
        return [gmlObjBuildMethodList $gmlObject(object,$tmpEntityName,class) 1]
      } else {
        return [gmlObjBuildMethodList $tmpEntityName 1]
      }
    } \
    "objects" {
      if { $tmpArgLen > 2 } {
        error "wrong #args: should be \"gmlObject info objects ?<className>?\""
      }
      if { $tmpArgLen == 1 } {
        set tmpList [list]
        foreach tmpClassName $gmlObject(classes) {
          set tmpList [concat $tmpList $gmlObject(class,$tmpClassName,objects)]
        }
        return $tmpList

      } else {
        set tmpClassName [lindex $args 1]
        if { ![gmlObjClassExists $tmpClassName] } {
          error "there is no class named \"$tmpClassName\""
        }
        return $gmlObject(class,$tmpClassName,objects)
      }
    } \
    "specializations" {
      if { $tmpArgLen != 2 } {
        error "wrong #args: should be \"gmlObject info specializations <className>\""
      }
      set tmpClassName [lindex $args 1]
      if { ! [info exists gmlObject(class,$tmpClassName,specializations)] } {
        error "there is no class named \"$tmpClassName\""
      }
      return $gmlObject(class,$tmpClassName,specializations)
    } \
    default {
      error "wrong option \"$tmpOption\": should be arglist, args, body, class, classes, classofobject, exists, interface, methods, objects, or specializations"
    }
}



