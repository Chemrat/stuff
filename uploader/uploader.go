package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"
)

var config = struct {
	UploadPath       string
	RemoteUploadPath string
	Password         string
}{
	UploadPath:       "./uploads/",
	RemoteUploadPath: "/uploads/",
	Password:         "password",
}

func downloadFromUrl(url string) string {
	tokens := strings.Split(url, "/")
	fileName := tokens[len(tokens)-1]
	fmt.Println("Downloading", url, "to", fileName)

	curdate := time.Now().Format("2006-01-02")
	uploadDir := config.UploadPath + curdate
	// XXX: Just ignore the error because directory probably exists?
	os.Mkdir(config.UploadPath+curdate, 0775)

	output, err := os.Create(uploadDir + "/" + fileName)
	if err != nil {
		fmt.Println("Error while creating", fileName, "-", err)
		return ""
	}
	defer output.Close()

	response, err := http.Get(url)
	if err != nil {
		fmt.Println("Error while downloading", url, "-", err)
		return ""
	}
	defer response.Body.Close()

	_, err = io.Copy(output, response.Body)
	if err != nil {
		fmt.Println("Error while downloading", url, "-", err)
		return ""
	}

	return config.RemoteUploadPath + curdate + "/" + fileName
}

func handler(w http.ResponseWriter, r *http.Request) {
	password := r.URL.Query().Get("password")
	url := r.URL.Query().Get("url")

	if password == config.Password {
		filepath := downloadFromUrl(url)
		if filepath != "" {
			http.Redirect(w, r, filepath, http.StatusFound)
		} else {
			io.WriteString(w, "Something went wrong")
		}
	} else {
		io.WriteString(w, "<html><head><title>Nope</title><body><img src=\"/uploads/loss_of_control.gif\" /></body></html>")
	}
}

func main() {
	http.HandleFunc("/", handler)
	http.ListenAndServe(":8000", nil)
}
