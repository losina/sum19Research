const fs = require('fs');
let rawdata = fs.readFileSync('gharchive-output-march.1.json');  
let student = JSON.parse(rawdata);  


count = 0 
student.forEach(element => {
  console.log(count++)
  console.log(element.repo_name)
});