data "template_file" "init_script" {
  template = "${file("install.sh")}"
}
