<template>
  <v-container>

    <v-toolbar color="primary">
      <v-toolbar-title class="white--text">{{ usuario.nombre }} {{ usuario.apellido }} </v-toolbar-title>
    </v-toolbar>

    <v-card>
        <br>
        <v-layout row>
            <v-flex xs12 md3 class="mx-5 mb-3">
                <div class="mb-3">
                    <b>Usuario:</b> {{ usuario.username }}
                </div>

                <div>
                    <b>Email:</b> {{ usuario.email }}
                </div>
            </v-flex>

            <v-flex xs12 md3 class="mx-5 mb-3">
                <div class="mb-3">
                    <b>Nombre:</b> {{ usuario.nombre }}
                </div>

                <div>
                    <b>Activo:</b> {{ usuario.activo | boolean }}
                </div>
            </v-flex>

            <v-flex xs12 md3 class="mx-5 mb-3">
                <div class="mb-3">
                    <b>Apellido:</b> {{ usuario.apellido }}
                </div>                

                <div>
                    <b>Rol:</b> {{ usuario.roles | roles }}
                </div>                
            </v-flex>
        </v-layout>

        <v-layout>
            <v-flex xs12 class="mx-5 mb-3">
                <div>
                    <b>Delegaciones:</b> {{ usuario.delegaciones | lista }}
                </div>                
            </v-flex>
        </v-layout>
    </v-card>
  </v-container>
</template>

<script>
import Vue from 'vue'
import api from '@/services/api'
import { Usuario } from '@/model/Usuario'
import MixinGlobalState from '@/components/mixins/MixinGlobalState'

export default {
    name: 'UsuarioDetalle',

    props: ['id'],

    mixins: [MixinGlobalState],

    data() {
        return {
            usuario: new Usuario(),
        }
    },

    filters: {
        lista: function(list) {
            if (!list) return '';
            return list.map(d => d.nombre).join(', ');
        },

        roles: function(list) {
            if (!list) return '';
            return list.map(r => this.opciones_globales.roles.find(rol => rol.value == r).text).join(', ');
        }
    },

    created: function() {
        this.update();
    },

    methods: {
        update: function() {
            return Promise.all([
                api.get('/delegaciones'),
                api.get(`/usuarios/${this.id}`),
                api.get(`/usuarios/${this.id}/delegaciones`)
            ])
            .then(r => {
                this.delegaciones = r[0].data;
                this.usuario = r[1].data;
                this.usuario.delegaciones = r[2].data;
            })
            .catch(e => console.error(e));
        }
    }

}
</script>

<style>

</style>
