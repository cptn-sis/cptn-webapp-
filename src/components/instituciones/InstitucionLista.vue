<template>
<v-container class="grey lighten-3">
  <v-toolbar class="darken-3" color="primary">
    <v-toolbar-title class="white--text">Instituciones</v-toolbar-title>
    <v-spacer></v-spacer>
  </v-toolbar>

  <v-card class="mt-4">
    <v-expansion-panel expand title="Filtros de Búsqueda">
      <v-expansion-panel-content v-model="expand_filtros" class="lighten-4" color="primary">
        <div slot="header"><b></b></div>
        <v-container class="white black--text">
          <v-layout row wrap>
            <v-flex xs12 md3 class="mx-4">
                <v-text-field 
                  v-model="filtros.nombre" 
                  label="Nombre" 
                  @input="updateList"
                  clearable
                ></v-text-field>
            </v-flex>

            <v-flex xs12 md3 class="mx-4">
                <v-text-field 
                  v-model="filtros.cue" 
                  label="CUE" 
                  @input="updateList"
                  clearable
                ></v-text-field>
            </v-flex>

            <v-flex xs12 md3 class="mx-4">
              <v-btn @click="limpiarFiltros">
                Limpiar Filtros
              </v-btn>
                            
            </v-flex>             
          </v-layout>

          <v-layout row wrap>
           
          </v-layout>
        </v-container>
      </v-expansion-panel-content>
    </v-expansion-panel>
  </v-card>

  <br>

    <v-data-table
      :headers="$options.headers"
      :items="instituciones"
      class="elevation-1"
      :no-data-text="loading ? '' : 'No se encontraron instituciones'"
      :no-results-text="loading ? '' : 'No se encontraron instituciones'"
      :pagination.sync="pagination"
      :total-items="totalItems"
      :loading="loading"
      :rows-per-page-items="[25,30,35]"
    >

      <template slot="items" slot-scope="props">
        <td class="justify-center layout px-0">
          <v-btn small icon class="mx-0" @click="verDetalle(props.item.id)">
            <v-icon color="primary">assignment</v-icon>
          </v-btn>

          <v-btn 
            v-if="$can('update', 'Institucion')"
            small icon class="mx-4" @click="editar(props.item.id)">
            <v-icon color="deep-purple">edit</v-icon>
          </v-btn>          
        </td>

        <td>{{ props.item.cue }}</td>
        <td>{{ props.item.nombre }}</td>
      </template>
    </v-data-table>

</v-container>
</template>

<script>

import api from '@/services/api'
import { debounce } from 'lodash'
import { ColumnHeader } from '@/model'
import ListaStore from '@/stores/listados/Instituciones'

export default {
  name: 'lista-solicitud',

  headers: [
    ColumnHeader('', 'acciones'),
    ColumnHeader('CUE', 'cue', true),
    ColumnHeader('Nombre', 'nombre', true)
  ],

  data() {
    return {
      pagination: ListaStore.state.pagination,
      filtros: ListaStore.state.filtros,
      totalItems: 0,
      loading: false,
      expand_filtros: true,
      instituciones: [],
      debouncedUpdate: null
    }
  },

  watch: {
    filtros: {
      handler() {
        this.pagination.page = 1;
        this.updateInstituciones();
      },
      deep: true
    },

    pagination: {
      handler() {
        this.updateInstituciones();
      },
      deep: true
    }
  },

  created: function() {
    this.debouncedUpdate = debounce(this.updateInstituciones, 800);
  },

  methods: {
    limpiarFiltros: function() {
      ListaStore.limpiarFiltros();
    },

    updateList: function() {
      this.debouncedUpdate();
    },

    updateInstituciones: function() {
      this.loading = true;
      this.instituciones = [];
      let offset = (this.pagination.page - 1) * this.pagination.rowsPerPage;
      let limit = this.pagination.rowsPerPage;

      let url = `/instituciones?limit=${limit}&offset=${offset}`;

      if (this.filtros.nombre) url += `&filtros[nombre]=${this.filtros.nombre}`;
      if (this.filtros.cue) url += `&filtros[cue]=${this.filtros.cue}`;

      if (this.pagination.sortBy) url+=`&sort=${this.pagination.descending ? '-' : '+'}${this.pagination.sortBy}`;

      api.get(url)
        .then(r => {
          this.instituciones = r.data.resultados;
          this.totalItems = r.data.totalQuery;
          this.loading = false;
        })
        .catch(e => console.error(e));
    },

    verDetalle: function(id) {
      this.$router.push(`/instituciones/${id}`);
    },  

    editar: function(id) {
      this.$router.push(`/instituciones/modificar/${id}`);
    },    

  }

}
</script>

<style>
</style>
