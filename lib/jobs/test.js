
const src_image = "src_image"
const dest_image = "dest_image"

var src_temp = require('temp').track(),
      dest_temp = require('temp').track(),
      fs = require('fs');
  try {
    src_temp.open('src_image', '.jpg', function(err, info) {
      if (!err) { fs.write(info.fd, src_image)
                fs.close(info.fd)
         }
      else throw err
    } )
    
    dest_temp.open('dest_image', '.jpg', function(err, info) {
      if (!err)
      {
      fs.write(info.fd, dest_image)
      fs.close(info.fd)
      }
      else 
        throw err

    })
  }
  catch (err) {
    throw err
  }
