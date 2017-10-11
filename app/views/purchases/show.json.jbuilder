<%- model_class = Purchase -%>
<div class="page-header">
  <h1><%=t '.title', :default => model_class.model_name.human.titleize %></h1>
</div>

<dl class="dl-horizontal">
  <dt><strong><%= model_class.human_attribute_name(:no) %>:</strong></dt>
  <dd><%= @purchase.no %></dd>
  <dt><strong><%= model_class.human_attribute_name(:fixed_asset_catalog_id) %>:</strong></dt>
  <dd><%= @purchase.fixed_asset_catalog.try(:name) %></dd>
  <dt><strong><%= model_class.human_attribute_name(:asset_name) %>:</strong></dt>
  <dd><%= @purchase.asset_name %></dd>
  
  <dt><strong><%= model_class.human_attribute_name(:brand_model) %>:</strong></dt>
  <dd><%= @purchase.brand_model %></dd>

  <dt><strong><%= model_class.human_attribute_name(:measurement_unit) %>:</strong></dt>
  <dd><%= @purchase.measurement_unit %></dd>
  <dt><strong><%= model_class.human_attribute_name(:amount) %>:</strong></dt>
  <dd><%= @purchase.amount %></dd>
  <dt><strong><%= model_class.human_attribute_name(:sum) %>:</strong></dt>
  <dd><%= @purchase.sum %></dd>
  <dt><strong><%= model_class.human_attribute_name(:buy_at) %>:</strong></dt>
  <dd><%= @purchase.buy_at %></dd>
  <dt><strong><%= model_class.human_attribute_name(:branch) %>:</strong></dt>
  <dd><%= @purchase.branch %></dd>
  <dt><strong><%= model_class.human_attribute_name(:relevant_unit_id) %>:</strong></dt>
  <dd><%= Unit.find_by(@purchase.relevant_unit_id).name %></dd>
  <dt><strong><%= model_class.human_attribute_name(:use_unit_id) %>:</strong></dt>
  <dd><%= Unit.find_by(@purchase.use_unit_id).name %></dd>
</dl>

<%= link_to t('.back', :default => t("helpers.links.back")),
              purchases_path, :class => 'btn btn-default'  %>
<%= link_to t('.edit', :default => t("helpers.links.edit")),
              edit_purchase_path(@purchase), :class => 'btn btn-default' %>
<%= link_to t('.destroy', :default => t("helpers.links.destroy")),
              purchase_path(@purchase),
              :method => 'delete',
              :data => { :confirm => t('.confirm', :default => t("helpers.links.confirm", :default => '确定删除?')) },
              :class => 'btn btn-danger' if can? :destroy, @purchase%>
