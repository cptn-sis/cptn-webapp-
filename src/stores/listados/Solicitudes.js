export default {
  state: {
      pagination: {
        page: 1,
        rowsPerPage: 25
      },

      filtros: {
        estado: null,
        tipoEntidad: 'profesional',
        numero: '',
        profesional: {
          dni: '',
          apellido: ''
        },
        empresa: {
          nombre: ''
        }
      },
  },

  setPagination(pagination){
    this.state.pagination = pagination;
  },

  setFiltros(filtros) {
    this.state.filtros = filtros;
  }
}


