<template>
<v-container>

  <v-dialog v-model="show_cambio_estado" persistent max-width="30%">
    <v-toolbar class="darken-3" color="primary">
      <v-toolbar-title class="white--text">Cambio de Estado de Legajo</v-toolbar-title>
    </v-toolbar>
    <v-card>
      <v-card-text class="grey lighten-4">
        <v-container>
            <v-layout row>
              <v-flex xs12 class="mx-4">
                <v-select
                  label="Estado:"
                  :items="global_state.opciones.estadoLegajo"
                  v-model="nuevo_estado"
                  item-text="valor"
                  item-value="id"
                ></v-select>
              </v-flex>
            </v-layout>

            <v-layout row class="ma-3">
              <v-flex xs12>
                <v-btn
                  class="right green white--text"
                  @click.native="submitEstado"
                  :disabled="!valid_estado_nuevo || submit_cambio"
                  :loading="submit_cambio"
                >
                  Guardar
                  <v-icon dark right>check_circle</v-icon>
                </v-btn>

                <v-btn class="right red white--text" @click.native="show_cambio_estado = false">
                  Cancelar
                  <v-icon dark right>block</v-icon>
                </v-btn>
              </v-flex>
            </v-layout>
        </v-container>
      </v-card-text>
    </v-card>
  </v-dialog>

  <v-layout row>
    <v-flex xs4 class="mx-4">
        <v-select
          :items="global_state.opciones.legajo"
          item-text="valor"
          item-value="id"
          v-model="filtros.tipo"
          label="Tipo"
          @input="updateList"
          clearable
        ></v-select>

        <v-select
          :items="global_state.opciones.estadoLegajo"
          item-text="valor"
          item-value="id"
          v-model="filtros.estado"
          label="Estado"
          @input="updateList"
          clearable
        ></v-select>

        <input-fecha
          label="Fecha Desde"
          clearable
          v-model="filtros.fecha_desde"
          @input="updateList"
        ></input-fecha>


        <v-text-field
          v-if="allFilters"
          v-model="filtros.numero_matricula"
          label="N° Matrícula"
          @input="updateList"
          clearable
        ></v-text-field>
    </v-flex>

    <v-flex xs4 class="mx-4">
        <v-text-field
          v-model="filtros.nomenclatura"
          label="Nomenclatura"
          @input="updateList"
          clearable
        ></v-text-field>

        <v-text-field
          v-model="filtros.numero"
          label="N° Legajo"
          @input="updateList"
          clearable
        ></v-text-field>

        <input-fecha
          label="Fecha Hasta"
          clearable
          v-model="filtros.fecha_hasta"
          @input="updateList"
        ></input-fecha>

        <v-text-field
          v-if="allFilters"
          v-model="filtros.domicilio.direccion"
          label="Dirección"
          @input="updateList"
          clearable
        ></v-text-field>
    </v-flex>

    <v-flex xs4 class="mx-4">
        <v-text-field
          v-model="filtros.comitente.nombre"
          label="Nombre Comitente"
          @input="updateList"
          clearable
        ></v-text-field>

        <v-text-field
          v-model="filtros.comitente.apellido"
          label="Apellido Comitente"
          @input="updateList"
          clearable
        ></v-text-field>
    </v-flex>
  </v-layout>

  <v-layout row wrap>
    <v-flex xs12>
      <v-card class="mt-5">
        <v-card-text>
          <v-btn
            v-if="showAdd"
            absolute dark fab top right
            color="green"
            @click="nuevoLegajo"
          >
            <v-icon>add</v-icon>
          </v-btn>

          <v-btn
            v-if="!allFilters"
            absolute dark fab top left
            color="primary"
            @click="imprimirLista"
          >
            <v-icon>print</v-icon>
          </v-btn>

          <v-btn
            v-if="allFilters"
            absolute dark fab top right
            color="primary"
            @click="exportar"
          >
            <v-icon>grid_on</v-icon>
          </v-btn>

          <v-data-table
              no-data-text=""
              :headers="headers"
              :items="legajos"
              :pagination.sync="pagination"
              :rows-per-page-items="[25,30,35]"
              :loading="loading"
              :total-items="total_items"
          >
            <template slot="items" slot-scope="props">
              <td>{{ props.item.fecha_solicitud | fecha }}</td>
              <td v-if="allFilters">{{ props.item.matricula.numeroMatricula }}</td>
              <td>{{ props.item.estado.valor }}</td>
              <td>{{ props.item.tipo.valor }}</td>
              <td>{{ props.item.numero_legajo }}</td>
              <td>{{ props.item.nomenclatura }}</td>
              <td>{{ props.item.comitentes | lista_comitentes }}</td>
              <td>{{ props.item.domicilio.direccion }}</td>

              <td>
                <v-menu>
                  <v-btn icon slot="activator" :disabled="!$can('update', 'Legajo')">
                    <v-icon class="blue--text">more_vert</v-icon>
                  </v-btn>

                  <v-list v-if="$can('update', 'Legajo')">
                    <v-list-tile @click="imprimir(props.item.id)" title="Imprimir">
                      <v-icon class="text--darken-2 mr-2">print</v-icon>
                      <v-list-tile-title>Imprimir</v-list-tile-title>
                    </v-list-tile>

                    <v-list-tile
                        v-if="props.item.estado.id == 1 || props.item.estado.id == 4"
                        title="Cambiar Estado"
                        @click="chgEstado(props.item)"
                    >
                      <v-icon color="primary" class="text--darken-2 mr-2">gavel</v-icon>
                      <v-list-tile-title>Cambiar Estado</v-list-tile-title>
                    </v-list-tile>

                    <v-list-tile
                        v-if="props.item.estado.id == 1 || props.item.estado.id == 4"
                        @click="editar(props.item.id)"
                    >
                      <v-icon color="deep-purple" class="text--darken-2 mr-2">edit</v-icon>
                      <v-list-tile-title>Modificar</v-list-tile-title>
                    </v-list-tile>

                    <v-list-tile
                      @click="verDetalle(props.item.id)"
                      title="Ver Detalle"
                    >
                      <v-icon color="primary" class="text--darken-2 mr-2">launch</v-icon>
                      <v-list-tile-title>Ver Detalle</v-list-tile-title>
                    </v-list-tile>
                  </v-list>
                </v-menu>
              </td>
            </template>
          </v-data-table>
        </v-card-text>
      </v-card>
    </v-flex>
  </v-layout>

    <table style="display:none" ref="tabla_export" id="tabla_export">
        <thead>
            <tr>
                <th style="text-align:right" v-for="header of headers" :key="header.value">
                    {{ header.text }}
                </th>
            </tr>
        </thead>
        <tbody>
        </tbody>
    </table>
</v-container>
</template>

<script>
import api from '@/services/api';
import reports from '@/services/reports'
import { debounce } from 'lodash'
import { ColumnHeader } from '@/model'
import InputFecha from '@/components/base/InputFecha'
import MixinGlobalState from '@/components/mixins/MixinGlobalState'

function getColumnHeaders(all) {
  let headers = [
      ColumnHeader('Fecha', 'fecha_solicitud', true),
      ColumnHeader('Estado', 'estado', true),
      ColumnHeader('Tipo', 'tipo', true),
      ColumnHeader('N° Legajo', 'numero', true),
      ColumnHeader('Nomenclatura', 'nomenclatura', true),
      ColumnHeader('Comitentes', 'comitentes'),
      ColumnHeader('Dirección', 'direccion', true),
      ColumnHeader('', 'acciones')
  ];

  if (all) {
    headers.splice(1, 0, ColumnHeader('N° Matrícula', 'numero_matricula', true));
  }

  return headers;

}

export default {

  name: 'LegajoLista',

  mixins: [MixinGlobalState],

  props: {
    id: Number,
    showAdd: Boolean,
    allFilters: {
      type: Boolean,
      default: () => false
    }
  },

  components: {
    InputFecha
  },

  filters: {
    lista_comitentes: function(lista) {
      return lista.map(c => `${c.persona.nombre} ${c.persona.tipo == 'fisica' ? c.persona.apellido : ''}`)
                  .join(', ');
    }
  },

  data () {
    return {
      headers: getColumnHeaders(this.allFilters),
      legajos: [],
      loading: false,

      show_cambio_estado: false,
      nuevo_estado: '',
      submit_cambio: false,

      filtros: {
        fecha_desde: '',
        fecha_hasta: '',
        numero: '',
        nomenclatura: '',
        tipo: '',
        numero_matricula: '',
        domicilio: {
          direccion: ''
        },
        comitente: {
          nombre: '',
          apellido: '',
        },
        estado: ''
      },

      total_items: 0,

      pagination: {
          page: 1,
          rowsPerPage: 25,
          descending: null,
          sortBy: null
      },

      debouncedUpdate: null,
    }
  },

  computed: {
    valid_estado_nuevo: function() {
      return this.nuevo_estado && this.nuevo_estado != this.legajo_select.estado.id;
    }
  },

  watch: {
    filtros: {
      handler() {
        this.pagination.page = 1;
        this.updateList();
      },
      deep: true,
      inmediate: true
    },

    pagination: {
      handler() {
        this.updateList();
      },
      deep: true,
      inmediate: true
    }
  },

  created: function() {
    this.debouncedUpdate = debounce(this.updateLegajos, 800);
    
    this.updateLegajos();
  },

  methods: {
    updateList: function() {
      this.debouncedUpdate();
    },

    updateLegajos: function() {
      this.loading = true;

      let url;
      this.legajo = [];
      let offset = (this.pagination.page - 1) * this.pagination.rowsPerPage;
      let limit = this.pagination.rowsPerPage;

      if (this.id) url = `/matriculas/${this.id}/legajos?&limit=${limit}&offset=${offset}`;
      else url = `/legajos?&limit=${limit}&offset=${offset}`;

      if (this.filtros.tipo) url += `&tipo=${this.filtros.tipo}`;
      if (this.filtros.estado) url += `&estado=${this.filtros.estado}`;
      if (this.filtros.fecha_desde) url += `&fecha[desde]=${this.filtros.fecha_desde}`;
      if (this.filtros.fecha_hasta) url += `&fecha[hasta]=${this.filtros.fecha_hasta}`;
      if (this.filtros.numero) url += `&filtros[numero]=${this.filtros.numero}`;
      if (this.filtros.nomenclatura) url += `&filtros[nomenclatura]=${this.filtros.nomenclatura}`;
      if (this.filtros.numero_matricula) url += `&filtros[matricula.numero]=${this.filtros.numero_matricula}`;
      if (this.filtros.comitente) {
        for(let f in this.filtros.comitente) {
          if (this.filtros.comitente[f]) url += `&filtros[comitente.${f}]=${this.filtros.comitente[f]}`;
        }
      }
      if (this.filtros.domicilio) {
        for(let f in this.filtros.domicilio) {
          if (this.filtros.domicilio[f]) url += `&filtros[domicilio.${f}]=${this.filtros.domicilio[f]}`;
        }
      }

      if (this.pagination.sortBy) url+=`&sort=${this.pagination.descending ? '-' : '+'}${this.pagination.sortBy}`;

      api.get(url)
      .then(r => {
        this.total_items = r.data.totalQuery;
        this.legajos = r.data.resultados;
        this.loading = false;
      })
      .catch(e => console.error(e));
    },

    verDetalle: function(id) {
      this.$router.push({ path: `/legajos/${id}` });
    },

    nuevoLegajo: function() {
      this.$router.push({ path: `/matriculas/${this.id}/nuevo-legajo` });
    },

    imprimir: function(legajo) {
      reports.open({
        'jsp-source': 'legajos_tecnicos.jasper',
        'jsp-format': 'PDF',
        'jsp-output-file': `Legajo N° ${legajo.numero_legajo} - ${Date.now()}`,
        'jsp-only-gen': false,
        'legajo_id': legajo
      });
    },

    editar: function(id) {
      this.$router.push({ path: `/legajos/${id}/modificar` });
    },

    chgEstado: function(legajo) {
      this.legajo_select = legajo;
      this.show_cambio_estado = true;
    },

    submitEstado: function() {
      this.submit_cambio = true;
      api.patch(`/legajos/${this.legajo_select.id}`, {
        estado: this.nuevo_estado
      })
      .then(r => {
        this.snackOk('Estado de matrícula modificado exitosamente!');
        this.submit_cambio = false;
        this.show_cambio_estado = false;
        this.updateList();
      })
      .catch(e => {
        this.submit_cambio = false;
        this.snackError(e);
      });
    },

    exportar: function() {
        this.global_state.cursor_wait = true;
        let tabla = this.$refs.tabla_export;

      let url = '/legajos?';

      if (this.filtros.tipo) url += `&tipo=${this.filtros.tipo}`;
      if (this.filtros.estado) url += `&estado=${this.filtros.estado}`;
      if (this.filtros.fecha_desde) url += `&fecha[desde]=${this.filtros.fecha_desde}`;
      if (this.filtros.fecha_hasta) url += `&fecha[hasta]=${this.filtros.fecha_hasta}`;
      if (this.filtros.numero) url += `&filtros[numero]=${this.filtros.numero}`;
      if (this.filtros.nomenclatura) url += `&filtros[nomenclatura]=${this.filtros.nomenclatura}`;
      if (this.filtros.numero_matricula) url += `&filtros[matricula.numero]=${this.filtros.numero_matricula}`;
      if (this.filtros.comitente) {
        for(let f in this.filtros.comitente) {
          if (this.filtros.comitente[f]) url += `&filtros[comitente.${f}]=${this.filtros.comitente[f]}`;
        }
      }
      if (this.filtros.domicilio) {
        for(let f in this.filtros.domicilio) {
          if (this.filtros.domicilio[f]) url += `&filtros[domicilio.${f}]=${this.filtros.domicilio[f]}`;
        }
      }

      if (this.pagination.sortBy) url+=`&sort=${this.pagination.descending ? '-' : '+'}${this.pagination.sortBy}`;

        api.get(url)
        .then(r => {
            let rows = '';
            for(let legajo of r.data.resultados) {
                rows += `
                <tr>
                  <td>${ this.$options.filters.fecha(legajo.fecha_solicitud) }</td>
                  <td>${ legajo.matricula.numeroMatricula }</td>
                  <td>${ legajo.estado.valor }</td>
                  <td>${ legajo.tipo.valor }</td>
                  <td>${ legajo.numero_legajo }</td>
                  <td>${ legajo.nomenclatura }</td>
                  <td>${ this.$options.filters.lista_comitentes(legajo.comitentes)}</td>
                  <td>${ legajo.domicilio.direccion }</td>
                </tr>
                `;
            }

            tabla.getElementsByTagName('tbody')[0].innerHTML = rows;

            window.open('data:application/vnd.ms-excel;base64,' + btoa(this.$refs.tabla_export.outerHTML));
            this.global_state.cursor_wait = false;
        })
        .catch(e => {
            console.error(e);
        })
    },


    imprimirLista: function() {
      reports.open({
        'jsp-source': 'listado_legajos_tecnicos.jasper',
        'jsp-format': 'PDF',
        'jsp-output-file': `Legajos - ${Date.now()}`,
        'jsp-only-gen': false,
        'matricula_id': this.id,
        'estado': this.filtros.estado || '0',
        'numero_legajo': this.filtros.numero || '0',
        'nomenclatura': this.filtros.nomenclatura || '0',
        'fecha_inicio': this.filtros.fecha_desde || '0',
        'fecha_fin': this.filtros.fecha_hasta || '0',
        'comitente_nombre': (this.filtros.comitente && this.filtros.comitente.nombre) ? 
          this.filtros.comitente.nombre :  '0',
        'comitente_apellido': (this.filtros.comitente && this.filtros.comitente.apellido) ? 
          this.filtros.comitente.apellido :  '0'
      });      
    }    
  },

}
</script>

<style>
</style>
