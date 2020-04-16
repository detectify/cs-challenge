from flask import Flask, request, render_template
app = Flask(__name__)

@app.route('/', methods=["GET"])
def admin():
    return render_template('admin.html')
    
def main():
    print("Running Admin Interface") 
   
if __name__ == '__main__':
    main()
    app.run(host='0.0.0.0', port=8888)
else:
    application = app