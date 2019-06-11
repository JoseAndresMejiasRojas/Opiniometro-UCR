﻿

namespace Opiniometro_WebApp.Models
{
    using System;
    using System.Collections.Generic;

    public partial class PersonaPerfilEnfasisModel
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public PersonaPerfilEnfasisModel()
        {
            
        }

        public Persona Persona { get; set; }
        public virtual ICollection<Enfasis> Enfasis { get; set; }

        public virtual ICollection<String> Perfil { get; set; }

    }
}