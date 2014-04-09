execute "Install HTTP_Request2" do
  command "pear install HTTP_Request2"
  not_if "pear list HTTP_Request2"
end