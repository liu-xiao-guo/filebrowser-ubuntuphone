.pragma library

var filetypes = [ "qml", "js", "apparmor", "desktop", "txt", "jpg", "png", "jpeg", "conf", "wav", "log", "mp4", "json", "accounts", "py"]

function isRecognizedFile(ext) {
    for ( var i in filetypes ) {
        if ( filetypes[i] === ext )
            return true
    }

    return false
}

var searchabletypes = [ "txt", "conf", "log"]

function isSearchable(ext) {
   for (var i in searchabletypes ) {
       if ( searchabletypes[ i ] === ext ) {
           return true;
       }
   }

   return false
}

var viewabletypes = [ "qml", "js", "apparmor", "desktop", "json", "accounts", "py" ]

function isViewable(ext) {
    for (var i in viewabletypes ) {
        if ( viewabletypes[ i ] === ext ) {
            return true;
        }
    }

    return false
}

