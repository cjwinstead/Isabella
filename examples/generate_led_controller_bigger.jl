using Isabella, YAML

data = YAML.load_file("examples/led_controller_bigger.yaml");
prj=generate_controller_project(data);
YAML.write_file("examples/generated_projects/led_controller_bigger_project.yaml",prj)

